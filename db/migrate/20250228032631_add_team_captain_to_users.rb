class AddTeamCaptainToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :team_captain, :boolean
  end
end
