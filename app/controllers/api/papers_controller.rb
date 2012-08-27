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
    temp_pdf = Tempfile.new('uploaded-pdf-')
    temp_pdf.binmode
    temp_pdf.write(params[:file].read)
    temp_pdf.flush
    temp_pdf.close
    # Calculate the hash
    uuid = Paper.calculate_uuid temp_pdf 
    # Create or get metadata
    metadata = Metadata.find_by_uuid(uuid)
    if not metadata
      # Extract metadata from PDF
      temp_pdf_path = temp_pdf.path
      
      metadata = create_metadata_from(temp_pdf_path, uuid)
    end
    # If the paper is uploaded again in the club, just update its timestamp
    paper = Paper.find_by_uuid(uuid)
    if paper and paper.touch
      render :json => paper
      return
    end
    # Save the paper in DB
    paper = Paper.create( title:    metadata.title, 
                          pub_date: metadata.pub_date,
                          num_pages: metadata.num_pages,
                          width:  metadata.width,
                          height: metadata.height,
                          uuid: uuid,
                          club_id: club.id, uploader_id: current_user.id)
    if paper
      render :json => paper
      # Convert the file from PDF to HTML5
      temp_pdf_basename = File.basename(temp_pdf_path, 
                                        File.extname(temp_pdf_path)) 
      html_dest_dir = Rails.root.join("uploads", uuid)
      # If PDF is not processed before, convert PDF to HTML
      unless File.directory?(html_dest_dir)
        # PDF -> HTML5
        Dir.mkdir html_dest_dir  
        cmd = "pdf2htmlEX --dest-dir #{html_dest_dir.to_s} #{temp_pdf_path.to_s}"
        pid = Process.spawn cmd

        # Move temp PDF file to its permanent location
        final_pdf_path = Rails.root.join("uploads", uuid, "fulltext.pdf")
        FileUtils.mv(temp_pdf_path, final_pdf_path)
        temp_pdf.unlink
      end
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

private
  def create_metadata_from pdf_file, uuid
    json_meta = %x[pdf2htmlEX --only-meta 1 "#{pdf_file}"] 
    parsed_meta = ActiveSupport::JSON.decode json_meta

    title = parsed_meta["title"]
    # Too short
    if title.mb_chars.length < 5
      title = params[:file].original_filename
    end
    # Too long
    if title.mb_chars.length > 100
      title = title.slice(0,100)
    end
    # Empty date
    pub_date = parsed_meta["modified_date"]
    if pub_date.empty?
      pub_date = nil
    end

    metadata = Metadata.create( title: title,
                                pub_date: pub_date,
                                num_pages: parsed_meta["num_pages"],
                                width: parsed_meta["width"],  
                                height: parsed_meta["height"],
                                uuid: uuid )
  end

end
