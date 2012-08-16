class AddNumPagesToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :num_pages, :integer
    rename_column :papers, :doc_hash, :uuid 
    add_index :papers, :uuid
  end
end
