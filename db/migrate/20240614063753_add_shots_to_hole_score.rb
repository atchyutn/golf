class AddShotsToHoleScore < ActiveRecord::Migration[7.1]
  def change
    add_column :hole_scores, :shots, :string
  end
end
