class RemoveColumnsFromRegion < ActiveRecord::Migration[7.1]
  def change
    remove_column :regions, :state, :string
    remove_column :regions, :country, :string
    add_column :regions, :name, :string
  end
end
