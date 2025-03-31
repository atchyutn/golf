class CreateGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :groups do |t|
      t.integer :tournament_id
      t.string :name

      t.timestamps
    end
  end
end
