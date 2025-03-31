class AddGroupPlayerIdsToTeam < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :group_player_ids, :integer, array: true, default: []
  end
end
