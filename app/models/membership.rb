class Membership < ActiveRecord::Base
  attr_accessible :role, :upload_tag_id, :club_id, :user_id

  belongs_to :club
  belongs_to :user 
end
