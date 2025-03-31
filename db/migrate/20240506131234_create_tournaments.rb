class CreateTournaments < ActiveRecord::Migration[7.1]
  def change
    create_table :tournaments do |t|
      t.string :name
      t.string :tournament_type
      t.string :url
      t.string :subdomain
      t.string :description
      t.boolean :open_signup
      t.boolean :hold_third_place_match
      t.decimal :pts_for_match_win
      t.decimal :pts_for_match_tie
      t.decimal :pts_for_game_win
      t.decimal :pts_for_game_tie
      t.decimal :pts_for_bye
      t.integer :swiss_rounds
      t.string :ranked_by
      t.boolean :accept_attachments
      t.boolean :hide_forum
      t.boolean :show_rounds
      t.boolean :private
      t.boolean :notify_users_when_matches_open
      t.boolean :notify_users_when_the_tournament_ends
      t.boolean :sequential_pairings
      t.integer :signup_cap
      t.datetime :start_at
      t.integer :check_in_duration
      t.integer :state, default: 0
      t.string :grand_finals_modifier

      t.timestamps
    end
  end
end
