class CreatePapers < ActiveRecord::Migration
  def change
    create_table :papers do |t|
      t.string :title
      t.date :pub_date
      t.string :hash
      t.integer :uploader_id

      t.timestamps
    end
  end
end
