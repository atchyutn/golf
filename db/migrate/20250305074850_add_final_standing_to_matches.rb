class AddFinalStandingToMatches < ActiveRecord::Migration[6.0]
  def change
    add_column :matches, :final_standing, :integer
  end
end