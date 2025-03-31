class AddMatchHandicapToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :match_handicap, :float
    remove_column :matches, :handicap, :float
  end
end
