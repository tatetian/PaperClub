class WelcomeController < ApplicationController
  skip_before_filter :authorize

  def index
  end

  def signin
  end

  def signup
  end
end
