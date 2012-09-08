class Notifer < ActionMailer::Base
  default from: "PaperClub<paperclub.mailer@gmail.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifer.send_invitation.subject
  #
  def send_invitation(invitation)
    @invitor    = User.find(invitation.invitor_id)
    @club       = Club.find(invitation.club_id)
    @invitation = invitation
    domain      = Rails.env == "production" ? "www.paperclub.com" : "localhost:3000" 
    @link       = "http://#{domain}/invitations/#{invitation.token}"
  
    mail  to: invitation.invitee_email,
          subject: "#{@invitor.fullname} invites you to join PaperClub"
  end
end
