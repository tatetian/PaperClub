class Api::TagsController < ApplicationController
  # List tags of a paper or a club
  #
  # URL         GET   /paper/<paper_id>/tags
  #             GET   /club/<club_id>/tags
  def index
    begin
      if params[:paper_id]
        # List tags of a paper
        paper = Paper.find(params[:paper_id])
        # Authenticate
        can_access_club?(paper.club_id)
        render :json => paper.tags
      else 
        # Authenticate
        club = can_access_club?(params[:club_id])
        # List tags of a club
        tags = club.tags.as_json(:include => [:num_papers])
        all_tag = { id: 0, 
                    name: "__all__", 
                    club_id: club.id, 
                    num_papers: club.papers.count
                  } 
        render :json => [all_tag] + tags 
      end
    rescue ActiveRecord::RecordNotFound
      error "Can't access the club or the paper"
    end
  end

  # Create a tag for a club or a paper
  # URL         POST  /paper/<paper_id>/tags
  #                   /club/<club_id>/tags
  # PARAMS      name
  def create
    begin
      if params[:paper_id]
        # Create a tag for the paper
        paper = Paper.find(params[:paper_id])
        # Authenticate
        club_id = paper.club_id
      else
        club_id = params[:club_id]
      end
      # Authenticate
      club = can_access_club?(club_id)
      # Tag name is lowercase
      name = params[:name].downcase
      # Find or create the tag for the club
      new_tag = Tag.find_or_create_by_club_id_and_name( club_id, 
                                                        params[:name] )
      if params[:paper_id]
        new_collection = Collection.find_or_create_by_paper_id_and_tag_id(
                           paper.id, new_tag.id)
      end
      render :json => new_tag 
    rescue ActiveRecord::RecordNotFound
      error "Can't access the club or the paper"
    end
  end 

  # Destroy a tag for a club or a paper
  # URL       DELETE  /paper/<paper_id>/tag/<id>
  #                   /club/<club_id>/tag/<id>
  def destroy
    begin
      if params[:paper_id]
        # Find the paper
        paper = Paper.find(params[:paper_id])
        # Authenticate
        can_access_club?(paper.club_id)
        # Find the collection that connects the tag & the paper
        tag = paper.tags.find(params[:id])
        collection = paper.collections.find_by_tag_id(params[:id])
        # Remove the tag from the paper
        if collection.destroy
          render :json => tag
        else
          error "Failed to destroy the tag"
        end
      else
        # Remove the tag from the club
        tag = Tag.find(params[:id])
        # Authenticate
        can_access_club?(tag.club_id)
        if tag.destroy
          render :json => tag
        else
          error "Failed to destroy the tag"
        end
      end
    rescue ActiveRecord::RecordNotFound
      error "Can't access the club or the paper"
    end
  end
end
