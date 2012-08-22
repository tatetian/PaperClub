class Metadata < ActiveRecord::Base
  attr_accessible :num_pages, :pub_date, :title, :uuid

  after_destroy :remove_files

  # Get the number of papers of this metadata
  def paper_count
    Paper.where(:uuid => self.uuid).count
  end

  def used?
    Paper.exists?(:uuid => self.uuid) 
  end

  def remove_files
    dir = self.get_dir
    begin
      FileUtils.rm_rf dir
    rescue
    end
  end

  def get_dir
    Rails.root.join("public", "uploads", self.uuid) 
  end
end
