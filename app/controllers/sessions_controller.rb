class SessionsController < ApplicationController
  skip_before_filter :authorize, :only => [:create] 

  # Signin
  def create
    user = User.find_by_email(params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      # Sign the user in and redirect to the user's show page.
      sign_in user

      redirect_back_or "/app"
    else
      # Create an error message and re-render the signin form.
      flash[:error] = 'Invalid email or password'
      redirect_to "/signin"
    end
  end

  # Signout
  def destroy
    sign_out
#    redirect_to root_path
#    render :json => {}
    redirect_to "/"
  end
end
