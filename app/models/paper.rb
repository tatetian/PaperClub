class Paper < ActiveRecord::Base
  attr_accessible :uuid, :pub_date, :title, :num_pages,
                  :width, :height,
                  :club_id, :uploader_id

  belongs_to :club

  has_many :collections, foreign_key: "paper_id"
  has_many :tags, through: :collections

  has_many :notes
  has_one  :news

  validate :title, presence: true
  validate :club_id, presence: true

  default_scope :order => 'papers.updated_at DESC'

  after_create {
    News.create_paper(self)
  }

  # Remove the associated metadata if no paper uses it
  after_destroy { |paper|
    metadata = Metadata.find_by_uuid(paper.uuid)
    if metadata and not metadata.used?
      metadata.destroy
    end
  }

  # Search papers in a club given keywords, tag and uploader
  def self.search(club_id, params={}) 
    params.reverse_merge! :offset => 0, :limit => 5

    conditions = ["papers.club_id=#{club_id}"]
    conditions << "papers.title LIKE ('%#{params[:keywords]}%')" if params[:keywords]
    conditions << "papers.uploader_id=#{params[:user_id]}" if params[:user_id]
    if(params[:tag_id])
      where << "collections.tag_id=#{params[:tag_id]}"
      return Paper.joins(:collections).where(conditions.join(" AND "))
                  .limit(params[:limit]).offset(params[:offset])
    else
      return Paper.where(conditions.join(" AND "))
                  .limit(params[:limit]).offset(params[:offset])
    end
  end

  # Get who uploaded the paper
  def uploader
    User.find(self.uploader_id)
  end

  # Set who uploaded the paper
  def uploader=(user_id)
    self.uploader_id = user_id
  end

  def as_json(options)
    {
      id:       self.id,
      title:    self.title, 
      pub_date: self.pub_date,
      num_pages: self.num_pages,
      width:    self.width,
      height:   self.height,
      tags:     self.tags.map { |t|
                  t.as_json(options)
                },
      club_id:  self.club_id,
      news:     self.news.as_json(options),
      created_at: self.created_at,
      updated_at: self.updated_at
    }
  end

  def self.create_from_metadata(metadata, user, club)
    uuid = metadata.uuid
    
    paper = club.papers.find_by_uuid(uuid)
    # if no such paper in the club
    if not paper 
      paper = Paper.create( title:      metadata.title, 
                            pub_date:   metadata.pub_date,
                            num_pages:  metadata.num_pages,
                            width:      metadata.width,
                            height:     metadata.height,
                            uuid:       uuid,
                            club_id:    club.id, 
                            uploader_id: user.id)
    # if the paper exists in the club
    else
      # update timestamp
      paper.touch
    end 
    paper
  end

  def self.create_from_file(pdf_path, user, club, options={})
    metadata = Metadata.find_or_create_from(pdf_path, options)

    paper = Paper.create_from_metadata(metadata, user, club)
  end
end
