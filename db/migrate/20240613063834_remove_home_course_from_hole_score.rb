class RemoveHomeCourseFromHoleScore < ActiveRecord::Migration[7.1]
  def change
    remove_reference :hole_scores, :home_course, null: false, foreign_key: true
  end
end
