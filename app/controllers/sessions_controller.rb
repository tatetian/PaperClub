class SessionsController < ApplicationController
  skip_before_filter :authorize, :only => [:create] 

  # Signin
  def create
    puts 'try to login...'
    user = User.find_by_email(params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      # Sign the user in and redirect to the user's show page.
      sign_in user
#      redirect_to root_path
      render :json => {}
      puts 'login'
    else
      # Create an error message and re-render the signin form.
      flash.now[:error] = 'Invalid email/password combination'
      # render or redirect
    end
  end

  # Signout
  def destroy
    sign_out
#    redirect_to root_path
    render :json => {}
  end

end
