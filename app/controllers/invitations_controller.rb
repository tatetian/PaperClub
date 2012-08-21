class InvitationsController < ApplicationController
  def accept
    invitation = Invitation.find_by_token(params[:token]) 
    email = invitation.invitee_email
    user = User.find_by_email(email)

    # If the email address is registered
    if user 
      if current_user.id == user.id 
        # Redirect to home
      else
        # Redirect to login
      end
    # Otherwise, then signup
    else 
      # Redirect to signup
    end
    render :json => "Not implemented yet" 
  end
end
