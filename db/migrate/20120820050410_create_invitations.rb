class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :club_id
      t.integer :invitor_id
      t.string :invitee_email
      t.string :role

      t.timestamps
    end
  end
end
