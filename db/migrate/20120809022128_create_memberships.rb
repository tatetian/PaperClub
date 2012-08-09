class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.string :role
      t.integer :upload_tag_id
      t.integer :club_id
      t.integer :user_id

      t.timestamps
    end
  end
end
