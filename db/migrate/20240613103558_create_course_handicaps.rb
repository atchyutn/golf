class CreateCourseHandicaps < ActiveRecord::Migration[7.1]
  def change
    create_table :course_handicaps do |t|
      t.float :final_handicap
      t.float :preview_handicap
      t.integer :user_id
      t.integer :match_id

      t.timestamps
    end
  end
end
