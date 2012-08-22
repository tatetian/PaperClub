class AddUuidIndexToMetadata < ActiveRecord::Migration
  def change
    add_index :metadata, :uuid, unique: true
  end
end
