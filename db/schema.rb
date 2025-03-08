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

ActiveRecord::Schema[8.0].define(version: 2025_03_08_222648) do
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
end
