class CreateHoles < ActiveRecord::Migration[6.0]
  def change
    create_table :holes do |t|
      t.integer :number, default: 0
      t.integer :par, default: 0
      t.references :home_course, null: false, foreign_key: true  # Add this line

      t.timestamps
    end
  end
end