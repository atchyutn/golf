class AddConfirmedToHoleScore < ActiveRecord::Migration[7.1]
  def change
    add_column :hole_scores, :confirmed, :boolean, default: false
  end
end
