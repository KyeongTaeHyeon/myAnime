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

ActiveRecord::Schema.define(version: 2026_02_09_000100) do

  create_table "anime", force: :cascade do |t|
    t.bigint "anilist_id", null: false
    t.string "title_romaji"
    t.string "title_english"
    t.string "title_native"
    t.string "status"
    t.string "season"
    t.integer "season_year"
    t.string "format"
    t.integer "episodes"
    t.integer "duration"
    t.string "source"
    t.string "cover_image_url"
    t.string "banner_image_url"
    t.integer "mean_score"
    t.integer "popularity"
    t.text "raw_json"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["anilist_id"], name: "index_anime_on_anilist_id", unique: true
    t.index ["season", "season_year"], name: "index_anime_on_season_and_season_year"
  end

  create_table "anime_likes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "anime_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["anime_id"], name: "index_anime_likes_on_anime_id"
    t.index ["user_id", "anime_id"], name: "index_anime_likes_on_user_id_and_anime_id", unique: true
    t.index ["user_id"], name: "index_anime_likes_on_user_id"
  end

  create_table "app_users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "display_name"
    t.string "role"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_app_users_on_email", unique: true
  end

  create_table "ingestion_states", force: :cascade do |t|
    t.string "provider", null: false
    t.datetime "next_allowed_at"
    t.string "last_error"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["provider"], name: "index_ingestion_states_on_provider", unique: true
  end

  create_table "news_articles", force: :cascade do |t|
    t.string "provider"
    t.string "external_id"
    t.string "title"
    t.text "description"
    t.string "url"
    t.string "image_url"
    t.datetime "published_at"
    t.text "raw_json"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["provider", "external_id"], name: "index_news_articles_on_provider_and_external_id", unique: true
    t.index ["provider"], name: "index_news_articles_on_provider"
    t.index ["published_at"], name: "index_news_articles_on_published_at"
  end

  create_table "quotes", force: :cascade do |t|
    t.string "source"
    t.string "character_name"
    t.text "quote_text"
    t.integer "anime_id"
    t.text "raw_json"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["anime_id"], name: "index_quotes_on_anime_id"
  end

  add_foreign_key "anime_likes", "anime"
  add_foreign_key "anime_likes", "app_users", column: "user_id"
  add_foreign_key "quotes", "anime"
end
