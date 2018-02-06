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

ActiveRecord::Schema.define(version: 20180131133457) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.integer  "journey_id"
    t.integer  "pickup_stop_id"
    t.integer  "dropoff_stop_id"
    t.string   "state"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "passenger_id"
    t.string   "phone_number"
    t.integer  "return_journey_id"
    t.integer  "number_of_passengers", default: 1
    t.text     "special_requirements"
    t.integer  "child_tickets",        default: 0
    t.integer  "older_bus_passes",     default: 0
    t.integer  "disabled_bus_passes",  default: 0
    t.integer  "scholar_bus_passes",   default: 0
    t.integer  "promo_code_id"
    t.string   "passenger_name"
    t.string   "payment_method",       default: "cash"
    t.integer  "pickup_landmark_id"
    t.integer  "dropoff_landmark_id"
    t.string   "email"
    t.string   "token"
    t.string   "cancellation_reason"
    t.string   "charge_id"
  end

  add_index "bookings", ["dropoff_landmark_id"], name: "index_bookings_on_dropoff_landmark_id", using: :btree
  add_index "bookings", ["dropoff_stop_id"], name: "index_bookings_on_dropoff_stop_id", using: :btree
  add_index "bookings", ["journey_id"], name: "index_bookings_on_journey_id", using: :btree
  add_index "bookings", ["passenger_id"], name: "index_bookings_on_passenger_id", using: :btree
  add_index "bookings", ["pickup_landmark_id"], name: "index_bookings_on_pickup_landmark_id", using: :btree
  add_index "bookings", ["pickup_stop_id"], name: "index_bookings_on_pickup_stop_id", using: :btree
  add_index "bookings", ["promo_code_id"], name: "index_bookings_on_promo_code_id", using: :btree
  add_index "bookings", ["return_journey_id"], name: "index_bookings_on_return_journey_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "journeys", force: :cascade do |t|
    t.integer  "route_id"
    t.datetime "start_time"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "open_to_bookings",  default: true
    t.boolean  "reversed"
    t.boolean  "booked",            default: false
    t.integer  "seats",             default: 0
    t.integer  "timetable_time_id"
    t.integer  "team_id"
  end

  add_index "journeys", ["route_id"], name: "index_journeys_on_route_id", using: :btree
  add_index "journeys", ["timetable_time_id"], name: "index_journeys_on_timetable_time_id", using: :btree

  create_table "landmarks", force: :cascade do |t|
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "stop_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "landmarks", ["stop_id"], name: "index_landmarks_on_stop_id", using: :btree

  create_table "passengers", force: :cascade do |t|
    t.string   "phone_number"
    t.string   "verification_code"
    t.datetime "verification_code_generated_at"
    t.boolean  "verified"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "name"
    t.string   "session_token",                  limit: 40
  end

  add_index "passengers", ["session_token"], name: "index_passengers_on_session_token", unique: true, using: :btree

  create_table "places", force: :cascade do |t|
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "places", ["slug"], name: "index_places_on_slug", unique: true, using: :btree

  create_table "promo_codes", force: :cascade do |t|
    t.decimal  "price_deduction"
    t.string   "code"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "que_jobs", id: false, force: :cascade do |t|
    t.integer  "priority",    limit: 2, default: 100,                                        null: false
    t.datetime "run_at",                default: "now()",                                    null: false
    t.integer  "job_id",      limit: 8, default: "nextval('que_jobs_job_id_seq'::regclass)", null: false
    t.text     "job_class",                                                                  null: false
    t.json     "args",                  default: [],                                         null: false
    t.integer  "error_count",           default: 0,                                          null: false
    t.text     "last_error"
    t.text     "queue",                 default: "",                                         null: false
  end

  create_table "routes", force: :cascade do |t|
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.json     "pricing_rule"
    t.boolean  "allow_concessions", default: true
    t.json     "geometry",          default: []
    t.integer  "route_id"
    t.text     "name"
  end

  add_index "routes", ["route_id"], name: "index_routes_on_route_id", using: :btree

  create_table "stops", force: :cascade do |t|
    t.integer  "route_id"
    t.integer  "position"
    t.integer  "minutes_from_last_stop"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "place_id"
  end

  add_index "stops", ["place_id"], name: "index_stops_on_place_id", using: :btree
  add_index "stops", ["route_id"], name: "index_stops_on_route_id", using: :btree

  create_table "suggested_edit_to_stops", force: :cascade do |t|
    t.integer  "passenger_id"
    t.integer  "stop_id"
    t.text     "description"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "suggested_edit_to_stops", ["passenger_id"], name: "index_suggested_edit_to_stops_on_passenger_id", using: :btree
  add_index "suggested_edit_to_stops", ["stop_id"], name: "index_suggested_edit_to_stops_on_stop_id", using: :btree

  create_table "suggested_journeys", force: :cascade do |t|
    t.integer  "passenger_id"
    t.integer  "route_id"
    t.datetime "start_time"
    t.text     "description"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "suggested_journeys", ["passenger_id"], name: "index_suggested_journeys_on_passenger_id", using: :btree
  add_index "suggested_journeys", ["route_id"], name: "index_suggested_journeys_on_route_id", using: :btree

  create_table "suggested_routes", force: :cascade do |t|
    t.integer  "passenger_id"
    t.text     "description"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "suggested_routes", ["passenger_id"], name: "index_suggested_routes_on_passenger_id", using: :btree

  create_table "supplier_suggestions", force: :cascade do |t|
    t.integer  "supplier_id"
    t.string   "url"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "supplier_suggestions", ["supplier_id"], name: "index_supplier_suggestions_on_supplier_id", using: :btree

  create_table "suppliers", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "team_id"
    t.string   "name"
    t.string   "phone_number"
    t.boolean  "admin"
    t.boolean  "approved",               default: false, null: false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

  add_index "suppliers", ["approved"], name: "index_suppliers_on_approved", using: :btree
  add_index "suppliers", ["email"], name: "index_suppliers_on_email", unique: true, using: :btree
  add_index "suppliers", ["reset_password_token"], name: "index_suppliers_on_reset_password_token", unique: true, using: :btree
  add_index "suppliers", ["team_id"], name: "index_suppliers_on_team_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "email"
  end

  create_table "timetable_times", force: :cascade do |t|
    t.time    "time"
    t.integer "timetable_id"
    t.integer "route_id"
    t.integer "seats",        default: 0
  end

  add_index "timetable_times", ["route_id"], name: "index_timetable_times_on_route_id", using: :btree

  create_table "timetables", force: :cascade do |t|
    t.date     "from"
    t.date     "to"
    t.integer  "route_id"
    t.boolean  "reversed",         default: false
    t.boolean  "open_to_bookings", default: true
    t.json     "days",             default: [0, 1, 2, 3, 4, 5, 6]
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "team_id"
  end

  add_foreign_key "bookings", "journeys"
  add_foreign_key "bookings", "passengers"
  add_foreign_key "bookings", "promo_codes"
  add_foreign_key "bookings", "stops", column: "dropoff_stop_id"
  add_foreign_key "bookings", "stops", column: "pickup_stop_id"
  add_foreign_key "journeys", "routes"
  add_foreign_key "landmarks", "stops"
  add_foreign_key "stops", "places"
  add_foreign_key "stops", "routes"
  add_foreign_key "suggested_edit_to_stops", "passengers"
  add_foreign_key "suggested_edit_to_stops", "stops"
  add_foreign_key "suggested_journeys", "passengers"
  add_foreign_key "suggested_journeys", "routes"
  add_foreign_key "suggested_routes", "passengers"
  add_foreign_key "supplier_suggestions", "suppliers"
  add_foreign_key "suppliers", "teams"
end
