class UserController < ApplicationController
#  before_filter :find_user, :only => [:update, :show, :destroy]
  
  # Create a new user(Signup)
  #
  # URL     POST http://www.paperclub.com/users/
  # PARAMS  fullname
  #         email
  #         password
  #         password_confirmation
  # ROLE    any
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      render :json => @user.to_hash 
    else
      error 'Failed to save new User record'
    end
  end

  # Update a user's info or settings
  #
  # PUT http://www.paperclub.com/user/<user_id>
  # PARAMS  fullname
  #         email
  # ROLE    self
  def update
    @user = User.find(params[:id])
#    unless signed_in?
#      error "Must sign in first"
#      return
#    end
#    unless @user.id == current_user.id
#      error "Can't change other user's info"
#      return
#    end
    unless @user.update_attributes(params[:user])
      error 'Failed to update'
      return
    end
    # OK
    render :json => @user.to_hash
  end

  # Show info of a user in a club
  #
  # URL     GET http://www.paperclub.com/club/<club_id>/user/<user_id>
  # ROLE    self, member
  def show
  #  @user = User.find(params[:id])
  #if current_user? @user  
  #    render :json => @user
  end

  # List all users in a club
  #   
  # GET http://www.paperclub.com/club/<club_id>/users
  # ROLE    member
  def index
  end

  # Remove a user from a club
  #
  # DESTROY http://www.paperclub.com/club/<club_id>/user/<user_id>
  # ROLE    admin
  def destroy
  end

private
  def error(message)
    flash[:error] = message
    render :json => {}
  end

  def fint_user
    @user = User.find(params[:id])
  end
end
