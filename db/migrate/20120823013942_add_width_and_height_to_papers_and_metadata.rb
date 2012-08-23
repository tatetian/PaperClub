class AddWidthAndHeightToPapersAndMetadata < ActiveRecord::Migration
  def change
    add_column :metadata, :width, :integer
    add_column :metadata, :height, :integer
    add_column :papers, :width, :integer
    add_column :papers, :height, :integer
  end
end
