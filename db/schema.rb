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

ActiveRecord::Schema[8.1].define(version: 2026_05_30_060000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "service_status", ["scheduled", "in_progress", "completed"]
  create_enum "user_role", ["user", "admin", "service_centre"]

  create_table "service_records", id: :serial, force: :cascade do |t|
    t.decimal "cost", precision: 10, scale: 2, null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.text "description"
    t.date "next_service_date"
    t.date "service_date", null: false
    t.integer "service_type_id", null: false
    t.integer "serviced_by"
    t.enum "status", default: "scheduled", enum_type: "service_status"
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.integer "vehicle_id", null: false
    t.index ["service_type_id"], name: "idx_service_records_service_type_id"
    t.index ["serviced_by"], name: "idx_service_records_serviced_by"
    t.index ["vehicle_id"], name: "idx_service_records_vehicle_id"
    t.check_constraint "cost >= 0::numeric", name: "service_records_cost_check"
  end

  create_table "service_types", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.text "name", null: false
    t.integer "recommended_days", null: false
    t.bigint "service_centre_id", null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.index "service_centre_id, lower(name)", name: "index_service_types_on_service_centre_id_and_lower_name", unique: true
    t.index ["service_centre_id"], name: "index_service_types_on_service_centre_id"
    t.check_constraint "recommended_days > 0", name: "service_types_recommended_days_check"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.text "email", null: false
    t.text "name", null: false
    t.text "password_digest", null: false
    t.enum "role", default: "user", enum_type: "user_role"
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }

    t.unique_constraint ["email"], name: "users_email_key"
  end

  create_table "vehicles", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.date "last_service_date"
    t.text "model", null: false
    t.text "name", null: false
    t.text "number_plate", null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.integer "user_id", null: false
    t.index ["user_id", "id"], name: "idx_vehicles_user_id_id"
    t.index ["user_id"], name: "idx_vehicles_user_id"
    t.unique_constraint ["number_plate"], name: "vehicles_number_plate_key"
  end

  add_foreign_key "service_records", "service_types", name: "service_records_service_type_id_fkey"
  add_foreign_key "service_records", "users", column: "serviced_by", name: "fk_serviced_by"
  add_foreign_key "service_records", "vehicles", name: "service_records_vehicle_id_fkey", on_delete: :cascade
  add_foreign_key "service_types", "users", column: "service_centre_id"
  add_foreign_key "vehicles", "users", name: "vehicles_user_id_fkey", on_delete: :cascade
end
