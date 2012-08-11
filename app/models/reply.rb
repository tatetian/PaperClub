class Reply < ActiveRecord::Base
  attr_accessible :content, :note_id, :user_id

  belongs_to :note
end
