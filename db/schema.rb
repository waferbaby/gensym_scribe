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

ActiveRecord::Schema[8.0].define(version: 2025_03_09_073211) do
  create_table "destiny_items", force: :cascade do |t|
    t.string "name"
    t.bigint "bungie_id"
    t.string "screenshot_url", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "item_type"
    t.integer "item_sub_type"
    t.integer "class_type"
    t.string "lore_entry"
    t.string "description"
    t.string "icon_url"
    t.integer "tier_type", default: 0
    t.string "summary"
    t.string "flavour_text"
    t.index ["bungie_id"], name: "index_destiny_items_on_bungie_id", unique: true
  end

  create_table "destiny_seasonal_acts", force: :cascade do |t|
    t.bigint "season_id"
    t.integer "position"
    t.integer "ranks"
    t.string "name"
    t.datetime "start_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id", "position"], name: "index_destiny_seasonal_acts_on_season_id_and_position"
  end

  create_table "destiny_seasons", force: :cascade do |t|
    t.bigint "bungie_id"
    t.string "name"
    t.string "description"
    t.integer "number"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "background_image_url"
    t.string "icon_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bungie_id"], name: "index_destiny_seasons_on_bungie_id", unique: true
  end
end
