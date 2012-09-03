class ApplicationController < ActionController::Base
  # All controllers need login by default; 
  # This is a whitelist policy. 
  # Those controllers that don't need login is specified by 
  # "skip_before_filter :authorize" explicitly.
  before_filter :authorize

#  protect_from_forgery

  include SessionsHelper
protected
  def authorize
    unless signed_in?
      store_location
      flash[:notice] = "Please signin"
      #redirect_to(:controller => "user", :action => "login")
      redirect_to "/signin"
    end
  end

  # Check whether the current user can access the club
  #
  # If yes, returns the club;
  # Otherwise raise a RecordNotFound exception
  def can_access_club? club_id
    current_user.clubs.find(club_id)
  end

  def error(message)
    flash[:error] = message
    render :json => {}
  end
end
