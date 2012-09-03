class AddPaperIdIndexToNews < ActiveRecord::Migration
  def change
    add_index :news, :paper_id
  end
end
