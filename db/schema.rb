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

ActiveRecord::Schema[7.1].define(version: 2025_04_04_134935) do
  create_table "competitions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games", force: :cascade do |t|
    t.integer "team_home_id", null: false
    t.integer "team_away_id", null: false
    t.integer "competition_id", null: false
    t.integer "goals_home"
    t.integer "goals_away"
    t.datetime "date"
    t.string "location"
    t.integer "match_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competition_id"], name: "index_games_on_competition_id"
    t.index ["team_away_id"], name: "index_games_on_team_away_id"
    t.index ["team_home_id"], name: "index_games_on_team_home_id"
  end

  create_table "participations", force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "competition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competition_id"], name: "index_participations_on_competition_id"
    t.index ["team_id"], name: "index_participations_on_team_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.integer "age"
    t.string "position"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "shortname"
    t.string "logo_url"
  end

  create_table "ticker_events", force: :cascade do |t|
    t.integer "ticker_id", null: false
    t.integer "user_id", null: false
    t.integer "team_id"
    t.integer "event_type"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_ticker_events_on_team_id"
    t.index ["ticker_id"], name: "index_ticker_events_on_ticker_id"
    t.index ["user_id"], name: "index_ticker_events_on_user_id"
  end

  create_table "tickers", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "user_id", null: false
    t.datetime "date"
    t.integer "goals_home"
    t.integer "goals_away"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ticker_state", default: 0, null: false
    t.index ["game_id"], name: "index_tickers_on_game_id"
    t.index ["user_id"], name: "index_tickers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.boolean "is_admin", default: false
  end

  add_foreign_key "games", "competitions"
  add_foreign_key "games", "teams", column: "team_away_id"
  add_foreign_key "games", "teams", column: "team_home_id"
  add_foreign_key "participations", "competitions"
  add_foreign_key "participations", "teams"
  add_foreign_key "players", "teams"
  add_foreign_key "ticker_events", "teams"
  add_foreign_key "ticker_events", "tickers"
  add_foreign_key "ticker_events", "users"
  add_foreign_key "tickers", "games"
  add_foreign_key "tickers", "users"
end
