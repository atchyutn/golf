class ChangeTeeAndHomeCourseColumns < ActiveRecord::Migration[7.1]
  def change
    remove_column :tees, :stroke_index_per_hole, :integer, array: true, default: []
    remove_column :tees, :par_per_hole, :integer, array: true, default: []
    add_column :home_courses, :stroke_index_per_hole, :integer, array: true, default: []
    add_column :home_courses, :par_per_hole, :integer, array: true, default: []
  end
end
