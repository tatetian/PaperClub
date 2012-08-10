class Paper < ActiveRecord::Base
  attr_accessible :doc_hash, :pub_date, :title, :club_id

  belongs_to :club

  has_many :collections, foreign_key: "paper_id"
  has_many :tags, through: :collections

  has_many :notes

  validate :title, presence: true
  validate :club_id, presence: true

  default_scope :order => 'papers.updated_at DESC'

  # Get who uploaded the paper
  def uploader
    User.find(self.uploader_id)
  end

  # Set who uploaded the paper
  def uploader=(user_id)
    self.uploader_id = user_id
  end

  def as_json(options)
    {
      id:       self.id,
      title:    self.title, 
      pub_date: self.pub_date,
      doc_hash: self.doc_hash,
      tags:     self.tags.map { |t|
                  t.as_json(options)
                }
    }
  end
end
