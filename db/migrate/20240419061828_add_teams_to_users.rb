class AddTeamsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :team_id, :integer
    add_column :users, :player_type, :integer, default: 0
    add_column :users, :invite_id, :integer
  end
end
