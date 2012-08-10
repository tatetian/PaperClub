class AddClubIdColumnToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :club_id, :integer
  end
end
