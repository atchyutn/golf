class ChangeHolesTableColumns < ActiveRecord::Migration[7.1]
  def change
    rename_column :holes, :handicap, :female_stroke
    rename_column :holes, :par, :female_par
    add_column :holes, :male_par, :integer, default: 0
    add_column :holes, :male_stroke, :integer, default: 0
  end
end
