class ChangeScoreTypeInHoleScores < ActiveRecord::Migration[6.0]
  def change
    change_column :hole_scores, :score, :integer, using: 'score::integer'
  end
end