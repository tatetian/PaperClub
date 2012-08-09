class Tag < ActiveRecord::Base
  attr_accessible :club_id, :name

  belongs_to :club

  has_many :collections, foreign_key: "tag_id"
  has_many :papers, through: :collections
  
  validate :club_id, presence: true
  validate :name, presence: true
end
