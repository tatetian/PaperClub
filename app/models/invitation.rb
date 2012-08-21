class Invitation < ActiveRecord::Base
  attr_accessible :club_id, :invitee_email, :invitor_id, :role, :token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :invitee_email, presence: true, format: { with: VALID_EMAIL_REGEX }
  validates :invitor_id, presence: true
  validates :club_id, presence: true

  before_save :init_token
  after_create :send_email

  def send_email
    Notifer.send_invitation(self).deliver
  end

  def init_token
    self.token = SecureRandom.urlsafe_base64
  end
end
