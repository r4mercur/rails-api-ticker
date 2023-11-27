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

ActiveRecord::Schema[7.1].define(version: 2023_11_27_164742) do
  create_table "competitions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games", force: :cascade do |t|
    t.integer "competition_id", null: false
    t.integer "team_home_id", null: false
    t.integer "team_away_id", null: false
    t.integer "team_home_score"
    t.integer "team_away_score"
    t.integer "match_day"
    t.datetime "date"
    t.string "location"
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

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
  end

  add_foreign_key "games", "competitions"
  add_foreign_key "games", "team_aways"
  add_foreign_key "games", "team_homes"
  add_foreign_key "participations", "competitions"
  add_foreign_key "participations", "teams"
end
