class Note < ActiveRecord::Base
  attr_accessible :content, :paper_id, :position, :user_id

  validate :content, presence: true
  validate :paper_id, presence: true
  validate :position, presence: true
  validate :user_id, presence: true

  belongs_to  :paper
  has_many    :replies, :dependent => :destroy

  default_scope :order => 'notes.created_at ASC'

  def as_json(options)
    user = User.find_by_id(self.user_id)
    {
      :id       => self.id,
      :date     => self.updated_at,
      :content  => self.content,
      :paper_id => self.paper_id,
      :user     => user.as_json(options),
      :replies  => self.replies.as_json(options)
    }
  end
end
