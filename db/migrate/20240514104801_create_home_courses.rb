class CreateHomeCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :home_courses do |t|
      t.string :name
      t.integer :holes
      t.integer :location_id

      t.timestamps
    end
  end
end
