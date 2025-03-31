class CreateTees < ActiveRecord::Migration[7.1]
  def change
    create_table :tees do |t|
      t.string :tee_id
      t.integer :home_course_id
      t.integer :club_id
      t.string :name
      t.string :slope_rating
      t.integer :course_par_for_tee
      t.integer :par_per_hole, array: true, default: []

      t.timestamps
    end
  end
end
