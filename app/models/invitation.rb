class Invitation < ActiveRecord::Base
  attr_accessible :club_id, :invitee_email, :invitor_id, :role
 
  after_create { |invitation| invitation.send_email }

  def send_email
    Notifer.send_invitation(self).deliver
  end
end
