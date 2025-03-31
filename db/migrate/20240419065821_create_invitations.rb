class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.integer :requester_id, null: false
      t.string :invitee_email
      t.boolean :is_accepted, default: false
      t.integer :team_id
      t.string :player_type

      t.timestamps
    end
  end
end
