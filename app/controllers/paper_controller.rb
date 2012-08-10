class PaperController < ApplicationController
  # List papers in a club
  #
  # URL     GET /club/<club_id>/papers
  # ROLE    member
  def index
    begin
      club = current_user.clubs.find(params[:club_id])
      render :json => club.papers
    rescue ActiveRecord::RecordNotFound
      error "Can't access the club"
    end
  end

  # Show the details of a paper in a club
  # URL     GET /club/<club_id>/paper/<paper_id>
  # ROLE    member
  def show
    begin
      paper = current_user.clubs.find(params[:club_id]).papers.find(params[:id])
      render :json => paper
    rescue ActiveRecord::RecordNotFound
        error "Can't access the club or the paper"
    end
  end

  # Upload a paper to a club
  #
  # URL     POST  /club/<club_id>/papers
  # ROLE    member
  def create

  end

  # Remove a paper from a club
  #
  # URL     DEL   /club/<club_id>/paper/<paper_id>
  # ROLE    member
  def destroy
    begin
      paper = current_user.clubs.find(params[:club_id]).papers.find(params[:id])
      if paper.destroy
        render :json => {id: paper.id}
      else
        error "Failed to destroy the record"
      end
    rescue ActiveRecord::RecordNotFound
      error "Can't access the club or paper"
    end
  end

  # Update the details of a paper
  #
  # URL     PUT /club/<club_id>/paper/<paper_id>
  # PARAMS  paper[title]
  #         paper[...]
  # ROLE    member
  #
  # To update the tags of a paper, use
  # TagsController
  def update
    begin
      paper = current_user.clubs.find(params[:club_id]).papers.find(params[:id])
      if paper.update_attributes(params[:paper])
        render :json => paper
      else
        error "Failed to update the record"
      end
    rescue ActiveRecord::RecordNotFound
      error "Can't access the club or paper"
    end
  end
end
