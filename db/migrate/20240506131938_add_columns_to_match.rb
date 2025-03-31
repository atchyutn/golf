class AddColumnsToMatch < ActiveRecord::Migration[7.1]
  def change
    add_column :matches, :tournament_id, :integer
    add_column :matches, :round, :integer
    add_column :matches, :match_id, :integer
    add_column :matches, :player1_id, :integer
    add_column :matches, :player2_id, :integer
    add_column :matches, :winner_id, :integer
    add_column :matches, :loser_id, :integer
    add_column :matches, :suggested_player_order, :integer
    add_column :matches, :scores_csv, :string, array:true, default: []
    add_column :users, :scores, :integer
  end
end
