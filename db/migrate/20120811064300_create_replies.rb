class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.text :content
      t.integer :user_id
      t.integer :note_id

      t.timestamps
    end
  end
end
