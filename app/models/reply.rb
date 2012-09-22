class Reply < ActiveRecord::Base
  attr_accessible :content, :note_id, :user_id

  belongs_to :note

  default_scope :order => 'created_at ASC'

  def as_json(options)
    user = User.find_by_id(self.user_id)
    {
      :id       => self.id,
      :content  => self.content,
      :user     => user.as_json(options)
    }
  end
end
