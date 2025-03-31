class RemoveScoresFromUser < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :scores, :integer
    add_column :teams, :final_standing, :integer
  end
end
