class Api::FulltextController < ApplicationController
  # Get the css for the paper
  #
  # URL     GET /api/fulltext/<paper_id>/all.css
  # PARAM   paper_id
  # ROLE    member
  def css
    # Find the paper
    paper = Paper.find(params[:paper_id])
    # Authenticate
    can_access_club?(paper.club_id)

    # Send file
    css_path = Rails.root.join("uploads", paper.uuid, "all.css")
    send_file css_path, :type=>"text/css", :disposition => 'inline', :x_sendfile=>true 
  end

  # Get the HTML of pages of the paper
  #
  # URL     GET /api/fulltext/<paper_id>/pages/<page_num>.html
  # PARAM   paper_id
  #         page_num
  # ROLE    member
  def pages
    # Find the paper
    paper = Paper.find(params[:paper_id])
    # Authenticate
    can_access_club?(paper.club_id)

    # Send file
    if params[:page_num]
      hex_page_num = params[:page_num].to_i.to_s(16)
      html_path = Rails.root.join("uploads", paper.uuid, "#{hex_page_num}.page")
      send_file html_path, :type=>"text/html", :disposition => 'inline', :x_sendfile=>true 
    end
  end

end
