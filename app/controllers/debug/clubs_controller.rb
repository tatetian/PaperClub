class Debug::ClubsController < ApplicationController
  def index
     
  end

  def show
    @club_id = params[:club_id]
  end
end
