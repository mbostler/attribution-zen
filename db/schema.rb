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

ActiveRecord::Schema.define(version: 20150301193524) do

  create_table "attribution_companies", force: :cascade do |t|
    t.string   "name"
    t.string   "cusip"
    t.string   "ticker"
    t.integer  "code_id"
    t.date     "effective_on"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "attribution_days", force: :cascade do |t|
    t.date     "date"
    t.integer  "portfolio_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "attribution_holding_codes", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attribution_holding_types", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attribution_holdings", force: :cascade do |t|
    t.float    "quantity"
    t.string   "ticker"
    t.string   "cusip"
    t.string   "security"
    t.float    "unit_cost"
    t.float    "total_cost"
    t.float    "price"
    t.float    "market_value"
    t.float    "pct_assets"
    t.float    "yield"
    t.integer  "company_id"
    t.integer  "code_id"
    t.integer  "type_id"
    t.integer  "day_id"
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
    t.string   "name",           null: false
    t.string   "human_name"
    t.string   "account_number"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
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
    t.integer  "company_id"
    t.integer  "day_id"
    t.integer  "portfolio_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "attribution_transaction_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attribution_transactions", force: :cascade do |t|
    t.string   "code"
    t.string   "security"
    t.integer  "quantity"
    t.date     "trade_date"
    t.date     "settle_date"
    t.string   "sd_type"
    t.string   "sd_symbol"
    t.float    "trade_amount"
    t.string   "cusip"
    t.string   "symbol"
    t.integer  "day_id"
    t.integer  "company_id"
    t.string   "close_method"
    t.string   "lot"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

end
