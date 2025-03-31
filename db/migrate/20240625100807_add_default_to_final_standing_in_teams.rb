class AddDefaultToFinalStandingInTeams < ActiveRecord::Migration[7.1]
  def change
    change_column_default :teams, :final_standing, 0
  end
end
