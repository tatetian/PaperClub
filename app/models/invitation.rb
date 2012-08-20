class Invitation < ActiveRecord::Base
  attr_accessible :club_id, :invitee_email, :invitor_id, :role

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :invitee_email, presence: true, format: { with: VALID_EMAIL_REGEX }
  validates :invitor_id, presence: true
  validates :club_id, presence: true

  after_create { |invitation| invitation.send_email }

  def send_email
    Notifer.send_invitation(self).deliver
  end
end
