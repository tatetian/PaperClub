class ApplicationController < ActionController::Base
  # All controllers need login by default; This is a whitelist policy. Those controllers that don't need login is specified by "skip_before_filter :authorize" explicitly.
  before_filter :authorize

  protect_from_forgery

  include SessionsHelper
protected
  def authorize
    unless signed_in?
      error("You haven't logged in")
    end
  end

  def error(message)
    flash[:error] = message
    render :json => {}
  end
end
