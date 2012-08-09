class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.integer :paper_id
      t.integer :tag_id

      t.timestamps
    end
  end
end
