class Paper < ActiveRecord::Base
  attr_accessible :doc_hash, :pub_date, :title, :club_id

  has_many :collections, foreign_key: "paper_id"
  has_many :tags, through: :collections

  has_many :notes

  validate :title, presence: true
  validate :club_id, presence: true

  # Get who uploaded the paper
  def uploader
    User.find(self.uploader_id)
  end

  # Set who uploaded the paper
  def uploader=(user_id)
    self.uploader_id = user_id
  end
end
