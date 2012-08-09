class Collection < ActiveRecord::Base
  attr_accessible :paper_id, :tag_id

  validates   :tag_id, presence: true
  validates   :paper_id, presence: true

  belongs_to  :tag
  belongs_to  :paper
end
