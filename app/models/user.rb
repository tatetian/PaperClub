class User < ActiveRecord::Base
  attr_accessible :avatar_url, :email, :fullname

  validates :fullname,  presence: true, length: { minimum: 1, maximum: 50 }  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format:     { with: VALID_EMAIL_REGEX }

end
