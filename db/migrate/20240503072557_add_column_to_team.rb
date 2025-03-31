class AddColumnToTeam < ActiveRecord::Migration[7.1]
  def up
    add_column :teams, :home, :boolean, default: false
  end

  def down
    remove_column :teams, :home, :boolean, default: false
  end
end
