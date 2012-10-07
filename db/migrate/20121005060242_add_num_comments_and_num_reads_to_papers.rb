class AddNumCommentsAndNumReadsToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :num_comments, :integer
    add_column :papers, :num_views,    :integer
  end
end
