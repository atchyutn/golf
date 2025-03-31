class AddGroupToTeam < ActiveRecord::Migration[7.1]
  def change
    add_column :teams, :group_id, :integer
  end
end
