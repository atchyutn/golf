class RemoveMatchesFromTeams < ActiveRecord::Migration[7.1]
  def change
    remove_column :teams, :match_id, :integer
  end
end
