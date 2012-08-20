class AddInviteeEmailIndexToInvitation < ActiveRecord::Migration
  def change
    add_index :invitations, :invitee_email
  end
end
