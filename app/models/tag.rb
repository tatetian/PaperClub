class Tag < ActiveRecord::Base
  attr_accessible :club_id, :name

  belongs_to :club

  has_many :collections, foreign_key: "tag_id", dependent: :destroy
  has_many :papers, through: :collections
  
  validate :club_id, presence: true
  validate :name, presence: true

  # Tag name should be lowercase
  before_save { |t| t.name = t.name.downcase }

  def as_json(options)
    if options[:include] and options[:include].include?(:num_papers)
      { id: self.id, name: self.name, club_id: self.club_id, num_papers: self.papers.count}
    else
      { id: self.id, name: self.name, club_id: self.club_id }
    end
  end
end
