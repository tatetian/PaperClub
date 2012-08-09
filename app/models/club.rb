class Club < ActiveRecord::Base
  attr_accessible :description, :name

  has_many :users, :through => :memberships
  has_many :memberships, :foreign_key => "club_id"

  has_many :tags

  validate :name, presence: true
end
