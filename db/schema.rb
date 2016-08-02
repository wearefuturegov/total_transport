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

ActiveRecord::Schema.define(version: 20160802123430) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.integer  "journey_id"
    t.integer  "pickup_stop_id"
    t.float    "pickup_lat"
    t.float    "pickup_lng"
    t.integer  "dropoff_stop_id"
    t.float    "dropoff_lat"
    t.float    "dropoff_lng"
    t.string   "state"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "bookings", ["dropoff_stop_id"], name: "index_bookings_on_dropoff_stop_id", using: :btree
  add_index "bookings", ["journey_id"], name: "index_bookings_on_journey_id", using: :btree
  add_index "bookings", ["pickup_stop_id"], name: "index_bookings_on_pickup_stop_id", using: :btree

  create_table "journeys", force: :cascade do |t|
    t.integer  "route_id"
    t.datetime "start_time"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "vehicle_id"
    t.integer  "supplier_id"
  end

  add_index "journeys", ["route_id"], name: "index_journeys_on_route_id", using: :btree
  add_index "journeys", ["supplier_id"], name: "index_journeys_on_supplier_id", using: :btree
  add_index "journeys", ["vehicle_id"], name: "index_journeys_on_vehicle_id", using: :btree

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

  create_table "suppliers", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "team_id"
    t.string   "name"
    t.string   "phone_number"
    t.boolean  "admin"
  end

  add_index "suppliers", ["email"], name: "index_suppliers_on_email", unique: true, using: :btree
  add_index "suppliers", ["reset_password_token"], name: "index_suppliers_on_reset_password_token", unique: true, using: :btree
  add_index "suppliers", ["team_id"], name: "index_suppliers_on_team_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vehicles", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "seats"
    t.string   "registration"
    t.string   "make_model"
    t.string   "colour"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "vehicles", ["team_id"], name: "index_vehicles_on_team_id", using: :btree

  add_foreign_key "bookings", "journeys"
  add_foreign_key "bookings", "stops", column: "dropoff_stop_id"
  add_foreign_key "bookings", "stops", column: "pickup_stop_id"
  add_foreign_key "journeys", "routes"
  add_foreign_key "journeys", "suppliers"
  add_foreign_key "journeys", "vehicles"
  add_foreign_key "stops", "routes"
  add_foreign_key "suppliers", "teams"
  add_foreign_key "vehicles", "teams"
end
