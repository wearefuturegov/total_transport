# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160713094021) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "journeys", force: :cascade do |t|
    t.integer  "route_id"
    t.datetime "start_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "journeys", ["route_id"], name: "index_journeys_on_route_id", using: :btree

  create_table "routes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stops", force: :cascade do |t|
    t.string   "name"
    t.integer  "route_id"
    t.float    "latitude"
    t.float    "longitude"
    t.json     "polygon"
    t.integer  "position"
    t.integer  "minutes_from_last_stop"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "stops", ["route_id"], name: "index_stops_on_route_id", using: :btree

  add_foreign_key "journeys", "routes"
  add_foreign_key "stops", "routes"
end
