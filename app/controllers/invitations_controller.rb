class InvitationsController < ApplicationController
  def accept
    invitation = Invitation.find_by_token(params[:token]) 
    email = invitation.invitee_email
    user = User.find_by_email(email)

    # If the email address is registered
    if user 
      user.accept_invitation(invitation)
      if signed_in?
        if current_user.id == user.id 
          redirect_to "/app"
        else
          sign_out
          redirect_to "/signin"
        end
      else
        redirect_to "/signin"
      end
    # Otherwise, then signup
    else 
      # Redirect to signup
      flash[:invitation] = params[:token]
      redirect_to "/signup"
    end
  end
end
