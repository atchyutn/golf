class AddCourseRatingToTee < ActiveRecord::Migration[7.1]
  def change
    add_column :tees, :course_rating, :float
  end
end
