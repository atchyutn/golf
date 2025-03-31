class AddRegionToTournament < ActiveRecord::Migration[7.1]
  def change
    add_column :tournaments, :region, :string
  end
end
