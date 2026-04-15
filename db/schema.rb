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

ActiveRecord::Schema[8.1].define(version: 2026_04_15_094500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "city"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "sector"
    t.string "size"
    t.datetime "updated_at", null: false
    t.string "website"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "last_seen_at"
    t.string "status", default: "warm", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_contacts_on_company_id"
    t.index ["last_seen_at"], name: "index_contacts_on_last_seen_at"
    t.index ["status"], name: "index_contacts_on_status"
  end

  create_table "deals", force: :cascade do |t|
    t.integer "amount", default: 0, null: false
    t.bigint "company_id", null: false
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "last_seen_at"
    t.string "name", null: false
    t.string "stage", default: "lead", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_deals_on_company_id"
    t.index ["contact_id"], name: "index_deals_on_contact_id"
    t.index ["last_seen_at"], name: "index_deals_on_last_seen_at"
    t.index ["stage"], name: "index_deals_on_stage"
  end

  create_table "notes", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "contact_id"
    t.datetime "created_at", null: false
    t.bigint "deal_id"
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_notes_on_contact_id"
    t.index ["deal_id"], name: "index_notes_on_deal_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.date "due_on", null: false
    t.string "priority", default: "medium", null: false
    t.string "status", default: "open", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_tasks_on_contact_id"
    t.index ["status", "due_on"], name: "index_tasks_on_status_and_due_on"
  end

  add_foreign_key "contacts", "companies"
  add_foreign_key "deals", "companies"
  add_foreign_key "deals", "contacts"
  add_foreign_key "notes", "contacts"
  add_foreign_key "notes", "deals"
  add_foreign_key "tasks", "contacts"
end
