class AddMatchHandicapToUsersTee < ActiveRecord::Migration[7.1]
  def change
    add_column :users_tees, :match_handicap, :float
    remove_column :users, :match_handicap, :float
  end
end
