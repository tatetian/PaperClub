class Club < ActiveRecord::Base
  attr_accessible :description, :name

  has_many :users, :through => :memberships
  has_many :memberships, :foreign_key => "club_id", :dependent => :destroy

  has_many :papers, :dependent => :destroy
  has_many :tags,   :dependent => :destroy

  validate :name, presence: true

  def as_json(options)
    admins = []
    {
      :id           => self.id, 
      :name         => self.name,
      :description  => self.description,
      :num_papers   => self.papers.size,
      :num_notes    => 0,
      :num_members  => self.users.count,
      :users        => self.users.map { |u|
                          if u.memberships.find_by_club_id(self.id).role == 'admin'
                            admins << u.id 
                          end
                          u.as_json(options)
                       },
      :admins       => admins
    }
  end

  default_scope :order => 'clubs.created_at DESC'

  def accep_member(user, role)
    membership = Membership.create(:club_id => club.id, 
                                   :user_id => user.id,
                                   :role => role)
  end

  def add_tag(name)
    tag = Tag.find_or_create_by_name(name, self.id)
  end

  def del_tag(name)
    tag = self.tags.find_by_name(name)
    tag.destroy
  end

  def self.join_member(club_id, user_id) 
    membership = Membership.create(:club_id => club_id, 
                                   :user_id => user_id,
                                   :role => "member")
  end

  #===============================================
  # Demo club
  #   A demo club is created with every new user
  #   to demonstrate features of PaperClub
  #
  # TODO: not hardcode demo papers' UUID but 
  # store them in database
  #===============================================

  @@demo_papers_uuid = ["fX+MBHVGPVl1SFL0odGFjQ", 
                        "0I9c9cA2fT1m6B71lxevMg", 
                        "R4faRsm5HLaffzRJ4gshDw", 
                        "NWAsJp_iYfniFGAJEwhedw", 
                        "8wULVYbd_sXaDXGTOKavqA", 
                        "kJ_7YNQt7p8AGzsM_bFzfw", 
                        "WmhmHRCENwbMtlz8+Ga6mQ"]

  @@demo_papers_correct_titles = {
    "fX+MBHVGPVl1SFL0odGFjQ" => "Reconstruction of the Genomes",
    "R4faRsm5HLaffzRJ4gshDw" => "How To Choose a Good Scientific Problem",
    "kJ_7YNQt7p8AGzsM_bFzfw" => "An Introduction To Compressive Sampling",
    "WmhmHRCENwbMtlz8+Ga6mQ" => "Spintronics: Fundamentals and applications"
  }

  def self.demo_papers_uuid
    @@demo_papers_uuid
  end

  # This is called in db/seed.rb to prepare for demo clubs
  def self.init_for_demo_clubs
    uuids = []

    demo_papers_dir = Rails.root.join("db", "data", "demo_papers")
    Dir.glob(demo_papers_dir + "*.pdf") do |pdf_path|
      metadata = Metadata.find_or_create_from pdf_path, 
                                              :force_create => true, 
                                              :preserve_src => true

      uuid = metadata.uuid

      correct_title = @@demo_papers_correct_titles[uuid]
      metadata.update_attributes(:title => correct_title) if correct_title

      uuids << uuid
    end

    uuids
  end
end
