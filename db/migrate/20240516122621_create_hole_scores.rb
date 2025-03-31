class CreateHoleScores < ActiveRecord::Migration[7.1]
  def change
    create_table :hole_scores do |t|
      t.references :home_course, null: false, foreign_key: true
      t.integer :hole_number
      t.string :score
      t.references :user, null: false, foreign_key: true
      t.references :match, null: false, foreign_key: true

      t.timestamps
    end
  end
end
