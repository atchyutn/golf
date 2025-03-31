class CreateTeeHoleInfos < ActiveRecord::Migration[7.1]
  def change
    create_table :tee_hole_infos do |t|
      t.references :hole, null: false, foreign_key: true  
      t.references :tee, null: false, foreign_key: true  
      t.integer :distance, default: 0  
      t.integer :par, default: 4  
      t.integer :handicap, default: 0
      
      t.timestamps
    end
  end
end
