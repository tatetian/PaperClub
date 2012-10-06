class Api::FulltextController < ApplicationController
  # Increment num_views counter
  #
  # URL     GET /api/fulltext/<paper_id>/counter
  # PARAM   paper_id
  # ROLE    member
  def counter
    # Find the paper
    paper = Paper.find(params[:paper_id])
    # Authenticate
    can_access_club?(paper.club_id)

    # Update counter
    Paper.increment_counter :num_views, paper.id

    render :nothing => true
  end

  # Check whether PDF to HTML processing is done
  #
  # URL     GET /api/fulltext/<paper_id>/ready?
  # PARAM   paper_id
  # ROLE    member
  def ready?
    # Find the paper
    paper = Paper.find(params[:paper_id])
    # Authenticate
    can_access_club?(paper.club_id)

    # Check existance of "done" file
    done_path = _get_done_path(paper)
    render :json => File.exists?(done_path)
  end
  
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
    page_num = params[:page_num].to_i
    if _page_ready?(paper, page_num)
      page_path = _get_page_path(paper, page_num)
      send_file page_path, :type => "text/html", :disposition => 'inline', 
                           :x_sendfile => true 
    else
      head :bad_request
    end
  end

  # Get the PDF of the paper
  #
  # URL     GET /api/fulltext/<paper_id>/download
  # PARAM   paper_id
  # ROLE    member
  def download
    # Find the paper
    paper = Paper.find(params[:paper_id])
    # Authenticate
    can_access_club?(paper.club_id)

    # Send file
    pdf_path = Rails.root.join("uploads", paper.uuid, "fulltext.pdf")
    send_file pdf_path, :type=>"application/pdf", :x_sendfile=>true 
  end

private
  def _get_page_path(paper, page_num)
    html_path = Rails.root.join("uploads", paper.uuid, "#{page_num}.page")
  end

  def _get_done_path(paper)
    Rails.root.join("uploads", paper.uuid, "all.css.done")
  end

  def _page_ready?(paper, page_num)
    if page_num < paper.num_pages
      File.exists?(_get_page_path(paper, page_num+1))
    elsif page_num == paper.num_pages
      File.exists?(_get_done_path(paper))
    else
      false
    end
  end
end
