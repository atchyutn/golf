class RenameGroupToCohors < ActiveRecord::Migration[7.1]
  def change
    rename_table :groups, :cohors
    rename_column :teams, :group_id, :cohors_id
  end
end
