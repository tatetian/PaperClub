class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.text :content
      t.string :position
      t.integer :user_id
      t.integer :paper_id

      t.timestamps
    end
  end
end
