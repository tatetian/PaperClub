class User < ActiveRecord::Base
  attr_accessible :avatar_url, :email, :fullname, 
                  :password, :password_confirmation,
                  :remember_token

  # user has many clubs through membership
  has_many :clubs, :through => :memberships
  has_many :memberships, :foreign_key => "user_id"

  has_secure_password 

  validates :fullname,  presence: true, length: { minimum: 1, maximum: 50 }  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password,  presence: true, length: { minimum: 6 }
  validates :password_confirmation, 
                        presence: true, length: { minimum: 6 }

  before_save { |user| user.email = email.downcase }
  before_save :init_remember_token

  def to_hash
    { :fullname => self.fullname, 
      :email    => self.email,
      :avatar_url => self.avatar_url }
  end

private
  def init_remember_token
    # SecureRandom.urlsafe_base64 returns a random string of length 16 
    # composed of the characters A–Z, a–z, 0–9, “-”, and “_”.  This means 
    # that the probability of two remember tokens being the same is
    #  1/64^16 = 2^{-96} ≈ 10^{-29}, which is negligible.
    #
    # If remember_token doesn't exist before, assign it a secure random
    self.remember_token ||= SecureRandom.urlsafe_base64
  end
end
