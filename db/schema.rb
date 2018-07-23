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

ActiveRecord::Schema.define(version: 2018_07_06_141440) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookings", id: :serial, force: :cascade do |t|
    t.integer "journey_id"
    t.integer "pickup_stop_id"
    t.integer "dropoff_stop_id"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "passenger_id"
    t.string "phone_number"
    t.integer "return_journey_id"
    t.integer "number_of_passengers", default: 1
    t.text "special_requirements"
    t.integer "child_tickets", default: 0
    t.integer "older_bus_passes", default: 0
    t.integer "disabled_bus_passes", default: 0
    t.integer "scholar_bus_passes", default: 0
    t.integer "promo_code_id"
    t.string "payment_method", default: "cash"
    t.integer "pickup_landmark_id"
    t.integer "dropoff_landmark_id"
    t.string "token"
    t.string "cancellation_reason"
    t.string "charge_id"
    t.boolean "survey_sent"
    t.text "missed_feedback"
    t.index ["dropoff_landmark_id"], name: "index_bookings_on_dropoff_landmark_id"
    t.index ["dropoff_stop_id"], name: "index_bookings_on_dropoff_stop_id"
    t.index ["journey_id"], name: "index_bookings_on_journey_id"
    t.index ["passenger_id"], name: "index_bookings_on_passenger_id"
    t.index ["pickup_landmark_id"], name: "index_bookings_on_pickup_landmark_id"
    t.index ["pickup_stop_id"], name: "index_bookings_on_pickup_stop_id"
    t.index ["promo_code_id"], name: "index_bookings_on_promo_code_id"
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "journeys", id: :serial, force: :cascade do |t|
    t.integer "route_id"
    t.datetime "start_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "open_to_bookings", default: true
    t.boolean "reversed"
    t.boolean "booked", default: false
    t.integer "timetable_time_id"
    t.integer "seats", default: 0
    t.integer "team_id"
    t.boolean "full?", default: false
    t.index ["route_id"], name: "index_journeys_on_route_id"
    t.index ["timetable_time_id"], name: "index_journeys_on_timetable_time_id"
  end

  create_table "landmarks", id: :serial, force: :cascade do |t|
    t.string "name"
    t.float "latitude"
    t.float "longitude"
    t.integer "stop_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stop_id"], name: "index_landmarks_on_stop_id"
  end

  create_table "passengers", id: :serial, force: :cascade do |t|
    t.string "phone_number"
    t.string "verification_code"
    t.datetime "verification_code_generated_at"
    t.boolean "verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.string "name"
    t.string "session_token", limit: 40
    t.string "email"
    t.index ["session_token"], name: "index_passengers_on_session_token", unique: true
  end

  create_table "places", id: :serial, force: :cascade do |t|
    t.string "name"
    t.float "latitude"
    t.float "longitude"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "route_count"
    t.index ["slug"], name: "index_places_on_slug", unique: true
  end

  create_table "pricing_rules", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "rule_type"
    t.integer "per_mile", default: 0
    t.jsonb "stages", default: {}, null: false
    t.float "child_multiplier", default: 0.5
    t.float "return_multiplier", default: 1.5
    t.boolean "allow_concessions", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "child_fare_rule", default: 0
    t.float "child_flat_rate"
  end

  create_table "promo_codes", id: :serial, force: :cascade do |t|
    t.decimal "price_deduction"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "que_jobs", primary_key: ["queue", "priority", "run_at", "job_id"], comment: "3", force: :cascade do |t|
    t.integer "priority", limit: 2, default: 100, null: false
    t.datetime "run_at", default: -> { "now()" }, null: false
    t.bigserial "job_id", null: false
    t.text "job_class", null: false
    t.json "args", default: [], null: false
    t.integer "error_count", default: 0, null: false
    t.text "last_error"
    t.text "queue", default: "", null: false
  end

  create_table "routes", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "allow_concessions", default: true
    t.json "geometry", default: []
    t.integer "route_id"
    t.text "name"
    t.integer "pricing_rule_id"
    t.index ["pricing_rule_id"], name: "index_routes_on_pricing_rule_id"
    t.index ["route_id"], name: "index_routes_on_route_id"
  end

  create_table "stops", id: :serial, force: :cascade do |t|
    t.integer "route_id"
    t.integer "position"
    t.integer "minutes_from_last_stop"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "place_id"
    t.index ["place_id", "route_id"], name: "index_stops_on_place_id_and_route_id"
    t.index ["place_id"], name: "index_stops_on_place_id"
    t.index ["route_id"], name: "index_stops_on_route_id"
  end

  create_table "suggested_edit_to_stops", id: :serial, force: :cascade do |t|
    t.integer "passenger_id"
    t.integer "stop_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["passenger_id"], name: "index_suggested_edit_to_stops_on_passenger_id"
    t.index ["stop_id"], name: "index_suggested_edit_to_stops_on_stop_id"
  end

  create_table "suggested_journeys", id: :serial, force: :cascade do |t|
    t.integer "passenger_id"
    t.integer "route_id"
    t.datetime "start_time"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["passenger_id"], name: "index_suggested_journeys_on_passenger_id"
    t.index ["route_id"], name: "index_suggested_journeys_on_route_id"
  end

  create_table "suggested_routes", id: :serial, force: :cascade do |t|
    t.integer "passenger_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["passenger_id"], name: "index_suggested_routes_on_passenger_id"
  end

  create_table "supplier_suggestions", id: :serial, force: :cascade do |t|
    t.integer "supplier_id"
    t.string "url"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supplier_id"], name: "index_supplier_suggestions_on_supplier_id"
  end

  create_table "suppliers", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
    t.string "name"
    t.string "phone_number"
    t.boolean "admin"
    t.boolean "approved", default: false, null: false
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.index ["approved"], name: "index_suppliers_on_approved"
    t.index ["email"], name: "index_suppliers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_suppliers_on_reset_password_token", unique: true
    t.index ["team_id"], name: "index_suppliers_on_team_id"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
  end

  create_table "timetable_times", id: :serial, force: :cascade do |t|
    t.time "time"
    t.integer "timetable_id"
    t.integer "route_id"
    t.integer "seats", default: 0
    t.index ["route_id"], name: "index_timetable_times_on_route_id"
  end

  create_table "timetables", id: :serial, force: :cascade do |t|
    t.date "from"
    t.date "to"
    t.integer "route_id"
    t.boolean "reversed", default: false
    t.boolean "open_to_bookings", default: true
    t.json "days", default: [0, 1, 2, 3, 4, 5, 6]
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
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
