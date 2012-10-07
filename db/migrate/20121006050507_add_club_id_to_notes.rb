class AddClubIdToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :club_id,      :integer

    add_column :clubs, :num_comments, :integer
    add_column :clubs, :num_papers,   :integer

    add_column :users, :num_papers,   :integer
  end
end
