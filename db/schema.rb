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

ActiveRecord::Schema.define(version: 20150216211153) do

  create_table "attribution_days", force: :cascade do |t|
    t.date     "date"
    t.integer  "portfolio_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "attribution_portfolio_days", force: :cascade do |t|
    t.integer  "day_id"
    t.float    "performance"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "attribution_portfolios", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attribution_securities", force: :cascade do |t|
    t.string   "cusip"
    t.string   "ticker"
    t.date     "effective_on"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "attribution_security_days", force: :cascade do |t|
    t.string   "cusip"
    t.float    "weight"
    t.float    "performance"
    t.float    "contribution"
    t.integer  "security_id"
    t.integer  "day_id"
    t.integer  "portfolio_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

end
