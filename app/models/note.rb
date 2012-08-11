class Note < ActiveRecord::Base
  attr_accessible :content, :paper_id, :position, :user_id

  validate :content, presence: true
  validate :paper_id, presence: true
  validate :position, presence: true
  validate :user_id, presence: true

  belongs_to  :paper
  has_many    :replies

  default_scope :order => 'notes.created_at DESC'
end
