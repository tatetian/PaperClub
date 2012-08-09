class AddIndexToMemberships < ActiveRecord::Migration
  def change
   add_index :memberships, :user_id
   add_index :memberships, :club_id
  end
end
