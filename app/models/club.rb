class Club < ActiveRecord::Base
  attr_accessible :description, :name

  has_many :users, :through => :memberships
  has_many :memberships, :foreign_key => "club_id"

  has_many :papers
  has_many :tags

  validate :name, presence: true

  def as_json(options)
    {
      :id           => self.id, 
      :name         => self.name,
      :description  => self.description,
      :papers_num   => self.papers.size,
      :notes_num    => 0,
      :users        => self.users.map { |u|
                          u.as_json(options)
                       }
    }
  end
end
