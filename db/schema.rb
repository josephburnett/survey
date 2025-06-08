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

ActiveRecord::Schema[8.0].define(version: 2025_06_08_221115) do
  create_table "answers", force: :cascade do |t|
    t.integer "question_id", null: false
    t.string "answer_type"
    t.string "string_value"
    t.float "number_value"
    t.boolean "bool_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "response_id"
    t.integer "user_id"
    t.boolean "deleted", default: false, null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["response_id"], name: "index_answers_on_response_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "metrics", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "source_type", null: false
    t.integer "source_id", null: false
    t.string "resolution"
    t.string "width"
    t.string "aggregation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted", default: false, null: false
    t.index ["source_type", "source_id"], name: "index_metrics_on_source"
    t.index ["user_id"], name: "index_metrics_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "question_type"
    t.float "range_min"
    t.float "range_max"
    t.boolean "deleted", default: false, null: false
    t.index ["user_id"], name: "index_questions_on_user_id"
  end

  create_table "questions_sections", id: false, force: :cascade do |t|
    t.integer "question_id", null: false
    t.integer "section_id", null: false
  end

  create_table "responses", force: :cascade do |t|
    t.integer "section_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.boolean "deleted", default: false, null: false
    t.index ["section_id"], name: "index_responses_on_section_id"
    t.index ["user_id"], name: "index_responses_on_user_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "name"
    t.string "prompt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.boolean "deleted", default: false, null: false
    t.index ["user_id"], name: "index_sections_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "responses"
  add_foreign_key "answers", "users"
  add_foreign_key "metrics", "users"
  add_foreign_key "questions", "users"
  add_foreign_key "responses", "sections"
  add_foreign_key "responses", "users"
  add_foreign_key "sections", "users"
end
