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
      flash[:fn_val] = user.fullname
      flash[:email_val] = user.email
      
      flash[:fn_error] = !!user.errors.messages[:fullname]
      flash[:pwd_error] = !!user.errors.messages[:password]
      flash[:email_error] = !!user.errors.messages[:email]
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
  
  def uploadAvatar
    avatar = Tempfile.new('uploaded-avatar-')
    avatar.binmode
    avatar.write(params[:file].read)
    avatar.flush
    avatar.close
    
    filename = params[:file].original_filename
    tmp_path = File.absolute_path(avatar.path)
    dest_pdf_path = Rails.root.join("public","avatars",filename)
    FileUtils.mv(tmp_path, dest_pdf_path)
    render :json=> ""
  end

private
  def fint_user
    @user = User.find(params[:id])
  end
end
