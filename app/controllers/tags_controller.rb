class TagsController < ApplicationController
  # List tags of a paper or a club
  #
  # URL         GET   /club/<club_id>/paper/<paper_id>/tags
  #             GET   /club/<club_id>/tags
  def index
    begin
      club = current_user.clubs.find(params[:club_id])
      if params[:paper_id]
        # List tags of a paper
        paper = club.papers.find(params[:paper_id])
        render :json => paper.tags
      else  
        # List tags of a club
        render :json => club.tags
      end
    rescue ActiveRecord::RecordNotFound
      error "Can't access the club or the paper"
    end
  end

  # Create a tag for a club or a paper
  # URL         POST  /club/<club_id>/paper/<paper_id>/tags
  #                   /club/<club_id>/tags
  # PARAMS      name
  def create
    begin
      # Find the club
      club = current_user.clubs.find(params[:club_id])
      # Tag name is lowercase
      name = params[:name].downcase
      # Find or create the tag for the club
      new_tag = Tag.find_or_create_by_club_id_and_name( params[:club_id], 
                                                        params[:name] )
      if params[:paper_id]
        # Create a tag for the paper
        paper = club.papers.find(params[:paper_id])
        new_collection = Collection.find_or_create_by_paper_id_and_tag_id(
                           paper.id, new_tag.id)
      end
      render :json => new_tag 
    rescue ActiveRecord::RecordNotFound
      error "Can't access the club or the paper"
    end
  end 

  # Destroy a tag for a club or a paper
  # URL       DELETE  /club/<club_id>/paper/<paper_id>/tag/<id>
  #                   /club/<club_id>/tag/<id>
  def destroy
    begin
      club = current_user.clubs.find(params[:club_id])
      if params[:paper_id]
        # Find the paper
        paper = club.papers.find(params[:paper_id])
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
        tag = club.tags.find(params[:id])
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
