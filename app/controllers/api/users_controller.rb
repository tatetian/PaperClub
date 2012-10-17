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
      if params[:password] and not params[:password].empty?
          current_user.update_attributes(attrs)
      else
          current_user.update_attribute(:fullname, attrs[:fullname])
      end

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
    
    avatar_size={"l"=>"96","m"=>"48","s"=>"32"}
    
    filename = SecureRandom.urlsafe_base64(15)+File.extname(params[:file].original_filename)
    tmp_path = File.absolute_path(avatar.path)
    
    dest_avatar_path = Rails.root.join("public","avatars","o",filename)
    FileUtils.mv(tmp_path, dest_avatar_path)
    
    avatar_size.each_pair{|k,v|
        path = Rails.root.join("public","avatars",k,filename)
        %x[convert "#{dest_avatar_path}" -resize #{v}x#{v}^ -gravity center -extent #{v}x#{v} "#{path}"]
    }
    
    old_url = current_user.avatar_url
    
    current_user.update_attribute(:avatar_url, filename)
    
    if old_url and old_url.length > 6
      avatar_size.each_pair{|k,v|
          path = Rails.root.join("public","avatars",k,old_url)
          File.delete(path);
      }
      File.delete(Rails.root.join("public","avatars","o",old_url));
    end
  end

private
  def fint_user
    @user = User.find(params[:id])
  end
end
