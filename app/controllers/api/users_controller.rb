class Api::UsersController < ApplicationController
  skip_before_filter :authorize, :only => [:create] 
  
  # Create a new user(Signup)
  #
  # URL     POST http://www.paperclub.com/api/users/
  # PARAMS  fullname
  #         email
  #         password
  #         password_confirmation
  # ROLE    any
  def create
    # Ignore password confirmation
    user = params[:user]
    user[:password_confirmation] = user[:password] 

    user = User.new(user)
    if user.save
      # In case signup action is redirected from invitation action
      if params[:invitation_token]
        invitation = Invitation.find_by_token(params[:invitation_token]) 
        user.accept_invitation invitation
      end

      sign_in user
      redirect_to "/app"
    else
      flash.now[:error] = "Invalid user information"
      redirect_to "/signup"
    end
  end

  # Update a user's info or settings
  #
  # PUT http://www.paperclub.com/user/<user_id>
  # PARAMS  fullname
  #         password
  #         password_confirmation
  # ROLE    self
  def update
    if params[:id].to_i == current_user.id 
      attrs = {}
      [:fullname, :password, :password_confirmation].each{ |key|
        attrs[key] = params[key] if params[key]
      }
      current_user.update_attributes(attrs)

      render :json => current_user
    else
      error 'Failed to update'
    end
  end

  # Show info of a user in a club
  #
  # URL     GET http://www.paperclub.com/user/<user_id>
  # ROLE    self, member
  def show
    if params[:id].to_i == current_user.id
      render :json => current_user
    else
      error "Access denied"
    end
  end

  # List all users in a club
  #   
  # GET http://www.paperclub.com/club/<club_id>/users
  # ROLE    member
  def index
    # Authenticate
    club = can_access_club?(params[:club_id])

    render :json => club.users.as_json(:club_id => club.id)
  end

  # Remove a user from a club
  #
  # DESTROY http://www.paperclub.com/club/<club_id>/user/<user_id>
  # ROLE    admin
  def destroy
  end

private
  def fint_user
    @user = User.find(params[:id])
  end
end
