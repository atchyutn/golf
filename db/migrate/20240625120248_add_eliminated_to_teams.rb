class AddEliminatedToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :eliminated, :boolean, default: false
  end
end
