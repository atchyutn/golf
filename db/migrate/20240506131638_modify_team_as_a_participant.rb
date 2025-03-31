class ModifyTeamAsAParticipant < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :tournament_id, :integer
    add_column :teams, :participant_id, :integer
    add_column :teams, :name, :string    
  end
end
