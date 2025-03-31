class AddHomeCourseToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :home_course_id, :integer
  end
end
