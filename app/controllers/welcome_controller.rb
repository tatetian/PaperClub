class WelcomeController < ApplicationController
  skip_before_filter :authorize

  def index
  end

  def signin
    if signed_in?
      redirect_to "/app"
    end 
  end

  def signup
    # In case signup action is redirected from invitation action
    @invitation_token = flash[:invitation]
  end
end
