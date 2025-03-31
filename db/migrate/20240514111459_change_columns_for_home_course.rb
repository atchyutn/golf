class ChangeColumnsForHomeCourse < ActiveRecord::Migration[7.1]
  def change
    reversible do |dir|
      dir.up do
        remove_column :matches, :address, :string
        add_column :teams, :home_course_id, :integer
        add_column :matches, :home_course_id, :integer
      end

      dir.down do
        add_column :matches, :address, :string
        remove_column :teams, :home_course_id
        remove_column :matches, :home_course_id
      end
    end
  end
end
