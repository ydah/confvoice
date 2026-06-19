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

ActiveRecord::Schema[8.1].define(version: 2026_06_19_000000) do
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

  create_table "conference_memberships", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.datetime "created_at", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["conference_id"], name: "index_conference_memberships_on_conference_id"
    t.index ["user_id", "conference_id"], name: "index_conference_memberships_on_user_id_and_conference_id", unique: true
    t.index ["user_id"], name: "index_conference_memberships_on_user_id"
  end

  create_table "conferences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "ends_on", null: false
    t.string "name", null: false
    t.boolean "published", default: false, null: false
    t.string "slug", null: false
    t.date "starts_on", null: false
    t.datetime "updated_at", null: false
    t.string "venue"
    t.index ["slug"], name: "index_conferences_on_slug", unique: true
  end

  create_table "feedbacks", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "rating"
    t.string "respondent_name", default: "", null: false
    t.string "respondent_token", null: false
    t.bigint "session_id", null: false
    t.boolean "speaker_visible", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["session_id", "respondent_token"], name: "index_feedbacks_on_session_id_and_respondent_token", unique: true
    t.index ["session_id", "speaker_visible", "created_at"], name: "idx_on_session_id_speaker_visible_created_at_cdf7eef514"
    t.index ["session_id"], name: "index_feedbacks_on_session_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "kind", null: false
    t.string "respondent_token", null: false
    t.bigint "session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id", "kind", "respondent_token"], name: "index_reactions_on_session_id_and_kind_and_respondent_token", unique: true
    t.index ["session_id"], name: "index_reactions_on_session_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.decimal "average_rating", precision: 3, scale: 2
    t.bigint "conference_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "ends_at", null: false
    t.boolean "feedback_open", default: true, null: false
    t.integer "feedbacks_count", default: 0, null: false
    t.string "room"
    t.string "slug", null: false
    t.string "speaker_name", null: false
    t.bigint "speaker_user_id"
    t.datetime "starts_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id", "slug"], name: "index_sessions_on_conference_id_and_slug", unique: true
    t.index ["conference_id"], name: "index_sessions_on_conference_id"
    t.index ["speaker_user_id"], name: "index_sessions_on_speaker_user_id"
  end

  create_table "speaker_invites", force: :cascade do |t|
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.bigint "session_id", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id", "revoked_at", "expires_at"], name: "idx_on_session_id_revoked_at_expires_at_0cd198d43c"
    t.index ["session_id"], name: "index_speaker_invites_on_session_id"
    t.index ["token"], name: "index_speaker_invites_on_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name", default: "", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "conference_memberships", "conferences"
  add_foreign_key "conference_memberships", "users"
  add_foreign_key "feedbacks", "sessions"
  add_foreign_key "reactions", "sessions"
  add_foreign_key "sessions", "conferences"
  add_foreign_key "sessions", "users", column: "speaker_user_id"
  add_foreign_key "speaker_invites", "sessions"
end
