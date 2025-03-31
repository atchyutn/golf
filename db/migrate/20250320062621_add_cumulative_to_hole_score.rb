class AddCumulativeToHoleScore < ActiveRecord::Migration[7.1]
  def change
    add_column :hole_scores, :winner, :string 
    add_column :hole_scores, :standing, :string
  end
end
