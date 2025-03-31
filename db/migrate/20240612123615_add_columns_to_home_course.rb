class AddColumnsToHomeCourse < ActiveRecord::Migration[7.1]
  def change
    add_column :home_courses, :course_id, :string
    add_column :home_courses, :course_par, :integer
    add_column :home_courses, :club_id, :integer
  end
end
