class Collection < ActiveRecord::Base
  attr_accessible :paper_id, :tag_id

  validates   :tag_id, presence: true
  validates   :paper_id, presence: true

  belongs_to  :tag
  belongs_to  :paper

  after_destroy :clear_tag

  def clear_tag
    # If this is the last collection of the tag, then delete the tag
    unless Collection.find_by_tag_id(self.tag_id)
      Tag.find(self.tag_id).destroy
    end
  end
end
