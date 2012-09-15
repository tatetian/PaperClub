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
  validates :password,  presence: true, length: { minimum: 1 }
  validates :password_confirmation, 
                        presence: true, length: { minimum: 1 }

  before_save { |user| 
    user.email = email.downcase 
  }

  before_create :init_remember_token
  before_create :init_avatar_url

  after_create { |user| 
    user.init_demo_club 
  }

  def as_json(options)
    { :id       => self.id,
      :fullname => self.fullname, 
      :email    => self.email,
      :avatar_url => self.avatar_url }
  end

  def join_club(club, role)
    _join_club(club.id, role)
  end

  def accept_invitation(invitation)
    _join_club(invitation.club_id, invitation.role)
  end

  def init_demo_club
    demo_club = Club.create(:name =>        "Explore PaperClub!", 
                            :description => "A demo club to help you discover PaperClub")
    self.join_club(demo_club, "admin")
    Club.demo_papers_uuid.each do |uuid|
      metadata = Metadata.find_by_uuid(uuid)
      if metadata
        paper = Paper.create_from_metadata(metadata, self, demo_club)
      end
    end
    
    demo_club
  end

  def init_avatar_url
    dropcap = Pinyin.t(self.fullname)[0].upcase 
    dropcap = [*'A'..'Z'].sample if dropcap < 'A' or dropcap > 'Z'
    
    self.avatar_url = dropcap + [*0..5].sample.to_s
  end
  
  def init_remember_token
    # SecureRandom.urlsafe_base64 returns a random string of length 16 
    # composed of the characters A–Z, a–z, 0–9, “-”, and “_”.  This means 
    # that the probability of two remember tokens being the same is
    #  1/64^16 = 2^{-96} ≈ 10^{-29}, which is negligible.
    #
    # If remember_token doesn't exist before, assign it a secure random
    puts 'init'
    self.remember_token ||= SecureRandom.urlsafe_base64
  end

  def self.init_all_avatars
    User.all.each { |u|
      if u.avatar_url == nil or u.avatar_url.empty?
        u.init_avatar_url
        u.save(:validate => false)
      end
    }
  end
private

  # Join a club
  def _join_club(club_id, role)
    # Make sure the user is not a member
    if Membership.find_by_user_id_and_club_id(self.id, club_id) == nil
      membership = Membership.create( :club_id => club_id, 
                                      :user_id => self.id,
                                      :role => role )
    end
  end
end
