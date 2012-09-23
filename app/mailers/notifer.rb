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
    @link       = "http://www.paperclub.com/invitations/#{invitation.token}"
  
    mail  to: invitation.invitee_email,
          subject: "#{@invitor.fullname}'s invitation is waiting for your response"
  end
end
