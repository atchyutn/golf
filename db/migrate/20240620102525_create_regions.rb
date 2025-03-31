class CreateRegions < ActiveRecord::Migration[7.1]
  def change
    create_table :regions do |t|
      t.string :state
      t.string :country

      t.timestamps
    end
    add_column :cohors, :region_id, :integer
    add_column :tournaments, :region_id, :integer
  end
end
