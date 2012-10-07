class SetDefaultValuesForCounters < ActiveRecord::Migration
  def up
    change_column :clubs, :num_comments, :integer, :default => 0
    change_column :clubs, :num_papers,   :integer, :default => 0

    remove_column :users, :num_papers

    change_column :papers, :num_views,   :integer, :default => 0
    change_column :papers, :num_comments,:integer, :default => 0
  end

  def down
  end
end
