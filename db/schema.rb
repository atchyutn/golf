# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_03_20_062621) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "chat_rooms", force: :cascade do |t|
    t.string "name"
    t.bigint "match_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_chat_rooms_on_match_id"
  end

  create_table "clubs", force: :cascade do |t|
    t.string "club_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.string "postal_code"
    t.string "city"
    t.string "state"
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.integer "number_of_holes"
  end

  create_table "cohors", force: :cascade do |t|
    t.integer "tournament_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "region_id"
    t.integer "tournament_type", default: 1
    t.string "game_name"
    t.datetime "starts_at"
    t.string "url"
    t.string "description"
    t.string "full_challonge_url"
    t.string "live_image_url"
    t.integer "state", default: 0
    t.boolean "is_final_tournament", default: false
  end

  create_table "course_handicaps", force: :cascade do |t|
    t.float "final_handicap"
    t.float "preview_handicap"
    t.integer "user_id"
    t.integer "match_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hole_scores", force: :cascade do |t|
    t.integer "hole_number"
    t.integer "score"
    t.bigint "user_id", null: false
    t.bigint "match_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "confirmed", default: false
    t.string "shots"
    t.string "winner"
    t.string "standing"
    t.index ["match_id"], name: "index_hole_scores_on_match_id"
    t.index ["user_id"], name: "index_hole_scores_on_user_id"
  end

  create_table "holes", force: :cascade do |t|
    t.integer "number", default: 0
    t.integer "female_par", default: 0
    t.bigint "home_course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "distance", default: 0
    t.integer "female_stroke", default: 0
    t.bigint "tee_id"
    t.integer "male_par", default: 0
    t.integer "male_stroke", default: 0
    t.index ["home_course_id"], name: "index_holes_on_home_course_id"
    t.index ["tee_id"], name: "index_holes_on_tee_id"
  end

  create_table "home_courses", force: :cascade do |t|
    t.string "name"
    t.integer "holes_count", default: 0
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "course_id"
    t.integer "course_par"
    t.integer "club_id"
    t.integer "stroke_index_per_hole", default: [], array: true
    t.integer "par_per_hole", default: [], array: true
    t.string "address"
    t.string "postal_code"
    t.string "city"
    t.string "state"
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.string "course_type"
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "invitee_email"
    t.boolean "is_accepted", default: false
    t.integer "team_id"
    t.string "player_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "match_teams", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_match_teams_on_match_id"
    t.index ["team_id"], name: "index_match_teams_on_team_id"
  end

  create_table "match_tees", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.bigint "tee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_match_tees_on_match_id"
    t.index ["tee_id"], name: "index_match_tees_on_tee_id"
  end

  create_table "matches", force: :cascade do |t|
    t.datetime "match_time"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tournament_id"
    t.integer "round"
    t.integer "match_id"
    t.integer "player1_id"
    t.integer "player2_id"
    t.integer "winner_id"
    t.integer "loser_id"
    t.integer "suggested_player_order"
    t.string "scores_csv", default: [], array: true
    t.integer "home_course_id"
    t.boolean "early_win", default: false
    t.integer "cohors_id"
    t.string "bracket"
    t.integer "final_standing"
  end

  create_table "message_reads", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "message_id", null: false
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_message_reads_on_message_id"
    t.index ["user_id"], name: "index_message_reads_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "chat_room_id", null: false
    t.bigint "user_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_room_id"], name: "index_messages_on_chat_room_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "regions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "home", default: false
    t.integer "tournament_id"
    t.integer "participant_id"
    t.string "name"
    t.integer "payment_status", default: 0
    t.string "paid_by"
    t.integer "home_course_id"
    t.integer "cohors_id"
    t.integer "group_player_ids", default: [], array: true
    t.integer "final_standing", default: 0
    t.boolean "eliminated"
    t.boolean "disqualified", default: false
  end

  create_table "tee_hole_infos", force: :cascade do |t|
    t.bigint "hole_id", null: false
    t.bigint "tee_id", null: false
    t.integer "distance", default: 0
    t.integer "par", default: 4
    t.integer "handicap", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hole_id"], name: "index_tee_hole_infos_on_hole_id"
    t.index ["tee_id"], name: "index_tee_hole_infos_on_tee_id"
  end

  create_table "tees", force: :cascade do |t|
    t.string "tee_id"
    t.integer "home_course_id"
    t.integer "club_id"
    t.string "name"
    t.string "slope_rating"
    t.integer "course_par_for_tee"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "course_rating"
    t.integer "total_distance", default: 0
    t.integer "gender", default: 0
    t.string "tee_color"
  end

  create_table "tournaments", force: :cascade do |t|
    t.string "name"
    t.string "tournament_type"
    t.string "url"
    t.string "subdomain"
    t.string "description"
    t.boolean "open_signup"
    t.boolean "hold_third_place_match"
    t.decimal "pts_for_match_win"
    t.decimal "pts_for_match_tie"
    t.decimal "pts_for_game_win"
    t.decimal "pts_for_game_tie"
    t.decimal "pts_for_bye"
    t.integer "swiss_rounds"
    t.string "ranked_by"
    t.boolean "accept_attachments"
    t.boolean "hide_forum"
    t.boolean "show_rounds"
    t.boolean "private"
    t.boolean "notify_users_when_matches_open"
    t.boolean "notify_users_when_the_tournament_ends"
    t.boolean "sequential_pairings"
    t.integer "signup_cap"
    t.datetime "start_at"
    t.integer "check_in_duration"
    t.integer "state", default: 0
    t.string "grand_finals_modifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "region"
    t.integer "region_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.string "country"
    t.string "postcode"
    t.string "magic_link_token"
    t.string "phone_number"
    t.string "handicap"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.boolean "active", default: false
    t.integer "team_id"
    t.integer "player_type", default: 0
    t.integer "invite_id"
    t.string "label"
    t.integer "home_course_id"
    t.boolean "team_captain"
    t.integer "active_chat_room_id"
    t.boolean "online", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_tees", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "tee_id", null: false
    t.integer "match_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "match_handicap"
    t.index ["tee_id"], name: "index_users_tees_on_tee_id"
    t.index ["user_id"], name: "index_users_tees_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chat_rooms", "matches"
  add_foreign_key "hole_scores", "matches"
  add_foreign_key "hole_scores", "users"
  add_foreign_key "holes", "home_courses"
  add_foreign_key "holes", "tees"
  add_foreign_key "match_teams", "matches"
  add_foreign_key "match_teams", "teams"
  add_foreign_key "match_tees", "matches"
  add_foreign_key "match_tees", "tees"
  add_foreign_key "message_reads", "messages"
  add_foreign_key "message_reads", "users"
  add_foreign_key "messages", "chat_rooms"
  add_foreign_key "messages", "users"
  add_foreign_key "tee_hole_infos", "holes"
  add_foreign_key "tee_hole_infos", "tees"
  add_foreign_key "users_tees", "tees"
  add_foreign_key "users_tees", "users"
end
