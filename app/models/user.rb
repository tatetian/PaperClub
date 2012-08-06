class User < ActiveRecord::Base
  attr_accessible :avatar_url, :email, :fullname, 
                  :password, :password_confirmation
  has_secure_password 

  validates :fullname,  presence: true, length: { minimum: 1, maximum: 50 }  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password,  presence: true, length: { minimum: 6 }
  validates :password_confirmation, 
                        presence: true, length: { minimum: 6 }

  before_save { |user| user.email = email.downcase }
end
