class AddColumnsToCsv < ActiveRecord::Migration[7.1]
  def change
    add_column :tees, :total_distance, :integer, default: 0
    add_column :tees, :gender, :integer, default: 0
    add_column :tees, :tee_color, :string
    add_column :home_courses, :course_type, :string
    add_column :clubs, :number_of_holes, :integer
    add_column :holes, :distance, :integer, default: 0
    add_column :holes, :handicap, :integer, default: 0
    add_reference :holes, :tee, foreign_key: true, null: true
    rename_column :home_courses, :holes, :holes_count
    change_column_default :home_courses, :holes_count, 0
  end
end