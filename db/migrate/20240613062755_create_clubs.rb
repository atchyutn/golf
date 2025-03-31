class CreateClubs < ActiveRecord::Migration[7.1]
  def change
    create_table :clubs do |t|
      t.string :club_id
      t.string :name
      t.integer :location_id

      t.timestamps
    end
  end
end
