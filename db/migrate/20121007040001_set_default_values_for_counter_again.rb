class SetDefaultValuesForCounterAgain < ActiveRecord::Migration
  def up
    change_column :clubs, :num_comments, :integer, :default => 0, :null => false
    change_column :clubs, :num_papers,   :integer, :default => 0, :null => false

    change_column :papers, :num_views,   :integer, :default => 0, :null => false
    change_column :papers, :num_comments,:integer, :default => 0, :null => false
  end

  def down
  end
end
