class News < ActiveRecord::Base
  attr_accessible :action, :detail, :paper_id, :user_id

  belongs_to :paper
   
  def self.create_paper(paper)
    News.create(paper_id: paper.id, user_id: paper.uploader_id, action: "uploaded")
  end

  def as_json(options)
    u = User.find(user_id)
    {
      :action => self.action,
      :detail => self.detail,
      :user   => u.fullname,
      :time => self.created_at
    }
  end
end
