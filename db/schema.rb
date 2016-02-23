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

ActiveRecord::Schema.define(version: 20160222061502) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bills", force: :cascade do |t|
    t.integer  "bill_number"
    t.string   "client_name"
    t.decimal  "net_amount",     precision: 15, scale: 3, default: 0.0
    t.decimal  "balance_to_pay", precision: 15, scale: 3, default: 0.0
    t.integer  "bill_type"
    t.integer  "status",                                  default: 0
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "fy_code"
  end

  add_index "bills", ["fy_code", "bill_number"], name: "index_bills_on_fy_code_and_bill_number", unique: true, using: :btree

  create_table "file_uploads", force: :cascade do |t|
    t.integer  "file"
    t.date     "report_date"
    t.boolean  "ignore",      default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "report"
    t.integer  "sub_report"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ledgers", force: :cascade do |t|
    t.string   "name"
    t.string   "client_code"
    t.decimal  "opening_blnc", precision: 15, scale: 3, default: 0.0
    t.decimal  "closing_blnc", precision: 15, scale: 3, default: 0.0
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "group_id"
  end

  create_table "particulars", force: :cascade do |t|
    t.decimal  "opening_blnc", precision: 15, scale: 3, default: 0.0
    t.integer  "trn_type"
    t.string   "description"
    t.string   "name"
    t.decimal  "amnt",         precision: 15, scale: 3, default: 0.0
    t.decimal  "running_blnc", precision: 15, scale: 3, default: 0.0
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "ledger_id"
    t.integer  "voucher_id"
  end

  create_table "share_transactions", force: :cascade do |t|
    t.decimal  "contract_no",      precision: 18
    t.string   "symbol"
    t.integer  "buyer"
    t.integer  "seller"
    t.string   "client_name"
    t.string   "client_code"
    t.integer  "quantity"
    t.decimal  "rate",             precision: 10, scale: 3, default: 0.0
    t.decimal  "share_amount",     precision: 15, scale: 3, default: 0.0
    t.decimal  "sebo",             precision: 15, scale: 3, default: 0.0
    t.decimal  "commission",       precision: 15, scale: 3, default: 0.0
    t.decimal  "dp_fee",           precision: 15, scale: 3, default: 0.0
    t.decimal  "cgt",              precision: 15, scale: 3, default: 0.0
    t.decimal  "net_amount",       precision: 15, scale: 3, default: 0.0
    t.decimal  "bank_deposit",     precision: 15, scale: 3, default: 0.0
    t.integer  "transaction_type"
    t.date     "date"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "bill_id"
  end

  create_table "users", force: :cascade do |t|
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
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "role"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vouchers", force: :cascade do |t|
    t.date     "date"
    t.string   "date_bs"
    t.string   "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
