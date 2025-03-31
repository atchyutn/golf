class RenameRequesterIdToUserIdInInvitations < ActiveRecord::Migration[7.1]
  def change
    rename_column :invitations, :requester_id, :user_id
  end
end
