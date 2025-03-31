class AddDisqualifiedToTeam < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :disqualified, :boolean, default: false
  end
end
