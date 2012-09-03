class CreateNews < ActiveRecord::Migration
  def change
    create_table :news do |t|
      t.integer :paper_id
      t.integer :user_id
      t.string :action
      t.string :detail

      t.timestamps
    end
  end
end
