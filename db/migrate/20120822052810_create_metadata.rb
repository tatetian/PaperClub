class CreateMetadata < ActiveRecord::Migration
  def change
    create_table :metadata do |t|
      t.string :uuid
      t.string :title
      t.date :pub_date
      t.integer :num_pages

      t.timestamps
    end
  end
end
