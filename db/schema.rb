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

ActiveRecord::Schema[8.1].define(version: 2026_05_27_102757) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "books", force: :cascade do |t|
    t.string "author"
    t.datetime "created_at", null: false
    t.date "finished_on"
    t.text "memo"
    t.date "started_on"
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "status"], name: "index_books_on_user_id_and_status"
    t.index ["user_id"], name: "index_books_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "diaries", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.date "date"
    t.text "image_data"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "date"], name: "index_diaries_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_diaries_on_user_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.integer "amount"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.date "date"
    t.text "memo"
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["category_id"], name: "index_expenses_on_category_id"
    t.index ["user_id"], name: "index_expenses_on_user_id"
  end

  create_table "health_logs", force: :cascade do |t|
    t.integer "condition"
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.string "memo", limit: 100
    t.decimal "sleep_hours", precision: 4, scale: 1
    t.decimal "temperature", precision: 4, scale: 1
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.decimal "weight", precision: 5, scale: 1
    t.index ["user_id", "date"], name: "index_health_logs_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_health_logs_on_user_id"
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.string "auth", null: false
    t.datetime "created_at", null: false
    t.string "endpoint", null: false
    t.string "p256dh", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["endpoint"], name: "index_push_subscriptions_on_endpoint", unique: true
    t.index ["user_id"], name: "index_push_subscriptions_on_user_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.time "end_time"
    t.string "memo", limit: 200
    t.time "start_time"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "date"], name: "index_schedules_on_user_id_and_date"
    t.index ["user_id"], name: "index_schedules_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "expense_target", default: 150000, null: false
    t.boolean "feature_book", default: true, null: false
    t.boolean "feature_diary", default: true, null: false
    t.boolean "feature_expense", default: true, null: false
    t.boolean "feature_health_log", default: true, null: false
    t.boolean "feature_schedule", default: true, null: false
    t.string "locale", default: "ja", null: false
    t.string "name"
    t.boolean "notify_books", default: false
    t.time "notify_books_time"
    t.boolean "notify_diary", default: false
    t.time "notify_diary_time"
    t.boolean "notify_entry", default: false
    t.time "notify_entry_time"
    t.boolean "notify_health", default: false
    t.time "notify_health_time"
    t.boolean "notify_schedule", default: false
    t.integer "notify_schedule_before", default: 10
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "books", "users"
  add_foreign_key "categories", "users"
  add_foreign_key "diaries", "users"
  add_foreign_key "expenses", "categories"
  add_foreign_key "expenses", "users"
  add_foreign_key "health_logs", "users"
  add_foreign_key "push_subscriptions", "users"
  add_foreign_key "schedules", "users"
end
