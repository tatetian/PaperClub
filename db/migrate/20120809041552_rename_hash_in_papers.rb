class RenameHashInPapers < ActiveRecord::Migration
  def change
    rename_column :papers, :hash,:doc_hash
  end
end
