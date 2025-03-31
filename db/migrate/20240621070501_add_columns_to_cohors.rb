class AddColumnsToCohors < ActiveRecord::Migration[7.1]
  def change
    add_column :cohors, :tournament_type, :integer, default: 1
    add_column :cohors, :game_name, :string
    add_column :cohors, :starts_at, :datetime
    add_column :cohors, :url, :string
    add_column :cohors, :description, :string
    add_column :cohors, :full_challonge_url, :string
    add_column :cohors, :live_image_url, :string
    add_column :cohors, :state, :integer, default: 0
  end
end
