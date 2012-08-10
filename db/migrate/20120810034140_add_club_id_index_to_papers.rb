class AddClubIdIndexToPapers < ActiveRecord::Migration
  def change
   add_index :papers, :club_id
  end
end
