class Api::PapersController < ApplicationController
  # List papers in a club
  #
  # URL     GET /club/<club_id>/papers
  # ROLE    member
  def index
    begin
      # Authenticate
      club = can_access_club?(params[:club_id])
      # Construct query
      params[:offset] = params[:offset].to_i  if params[:offset]
      params[:limit]  = params[:limit].to_i   if params[:limit]
      render :json => Paper.search(club.id, params)
    rescue ActiveRecord::RecordNotFound
      error "Can't access the club"
    end
  end

  # Show the details of a paper in a club
  #
  # URL     GET /paper/<paper_id>
  # ROLE    member
  def show
    begin
      # Find the paper
      paper = Paper.find(params[:id])
      # Authenticate
      club = can_access_club?(paper.club_id)
      render :json => paper
    rescue ActiveRecord::RecordNotFound
        error "Can't access the club or the paper"
    end
  end

  # Upload a paper to a club
  #
  # URL     POST  /club/<club_id>/papers
  # ROLE    member
  require "tempfile"
  def create
    # Authenticate
    club = can_access_club?(params[:club_id])

    # Save the uploaded file as a tempfile
    temp_file = Tempfile.new('uploaded-pdf-')
    temp_file.binmode
    temp_file.write(params[:file].read)
    temp_file.flush
    temp_file.close

    filename = params[:file].original_filename
    paper = Paper.create_from_file temp_file.path, current_user, club,
              :default_titile => File.basename(filename, File.extname(filename))

    if paper
      render :json => paper
    else
      error "Can't save in database"
    end
  end

  # Remove a paper from a club
  #
  # URL     DEL   /paper/<paper_id>
  # ROLE    member
  def destroy
    begin
      # Find the paper
      paper = Paper.find(params[:id])
      # Authenticate
      can_access_club?(paper.club_id)
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
      # Find the paper
      paper = Paper.find(params[:id])
      # Authenticate
      can_access_club?(paper.club_id)
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
