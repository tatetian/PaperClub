class AddPaperAndTagIndexToCollection < ActiveRecord::Migration
  def change
   add_index :collections, :tag_id
   add_index :collections, :paper_id
  end
end
