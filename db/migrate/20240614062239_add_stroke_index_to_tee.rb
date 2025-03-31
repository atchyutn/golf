class AddStrokeIndexToTee < ActiveRecord::Migration[7.1]
  def change
    add_column :tees, :stroke_index_per_hole, :integer, array: true, default: []
  end
end
