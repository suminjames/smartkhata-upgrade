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

ActiveRecord::Schema.define(version: 20160311125031) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bank_accounts", force: :cascade do |t|
    t.string   "name"
    t.integer  "account_number"
    t.string   "address"
    t.integer  "contact_number"
    t.boolean  "default_for_purchase"
    t.boolean  "default_for_sales"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "bills", force: :cascade do |t|
    t.integer  "bill_number"
    t.string   "client_name"
    t.decimal  "net_amount",        precision: 15, scale: 2, default: 0.0
    t.decimal  "balance_to_pay",    precision: 15, scale: 2, default: 0.0
    t.integer  "bill_type"
    t.integer  "status",                                     default: 0
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "fy_code"
    t.integer  "client_account_id"
  end

  add_index "bills", ["fy_code", "bill_number"], name: "index_bills_on_fy_code_and_bill_number", unique: true, using: :btree

  create_table "cheque_entries", force: :cascade do |t|
    t.integer  "cheque_number"
    t.integer  "bank_account_id"
    t.integer  "particular_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "client_accounts", force: :cascade do |t|
    t.string   "boid"
    t.string   "nepse_code"
    t.date     "date"
    t.string   "name"
    t.string   "address1",            default: " "
    t.string   "address1_perm"
    t.string   "address2",            default: " "
    t.string   "address2_perm"
    t.string   "address3"
    t.string   "address3_perm"
    t.string   "city",                default: " "
    t.string   "city_perm"
    t.string   "state"
    t.string   "state_perm"
    t.string   "country",             default: " "
    t.string   "country_perm"
    t.string   "phone"
    t.string   "phone_perm"
    t.string   "customer_product_no"
    t.string   "dp_id"
    t.string   "dob"
    t.string   "sex"
    t.string   "nationality"
    t.string   "stmt_cycle_code"
    t.string   "ac_suspension_fl"
    t.string   "profession_code"
    t.string   "income_code"
    t.string   "electronic_dividend"
    t.string   "dividend_curr"
    t.string   "email"
    t.string   "father_husband"
    t.string   "citizen_passport"
    t.string   "granfather_spouse"
    t.string   "purpose_code_add"
    t.string   "add_holder"
    t.boolean  "invited",             default: false
    t.integer  "user_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

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

  create_table "isin_infos", force: :cascade do |t|
    t.string   "company"
    t.string   "isin"
    t.string   "sector"
    t.decimal  "max",        precision: 10, scale: 2, default: 0.0
    t.decimal  "min",        precision: 10, scale: 2, default: 0.0
    t.decimal  "last_price", precision: 10, scale: 2, default: 0.0
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  create_table "ledgers", force: :cascade do |t|
    t.string   "name"
    t.string   "client_code"
    t.decimal  "opening_blnc",      precision: 15, scale: 2, default: 0.0
    t.decimal  "closing_blnc",      precision: 15, scale: 2, default: 0.0
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "group_id"
    t.integer  "bank_account_id"
    t.integer  "client_account_id"
  end

  create_table "particulars", force: :cascade do |t|
    t.decimal  "opening_blnc",     precision: 15, scale: 2, default: 0.0
    t.integer  "transaction_type"
    t.integer  "cheque_number"
    t.string   "name"
    t.string   "description"
    t.decimal  "amnt",             precision: 15, scale: 2, default: 0.0
    t.decimal  "running_blnc",     precision: 15, scale: 2, default: 0.0
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "ledger_id"
    t.integer  "voucher_id"
    t.integer  "bill_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.string   "name"
    t.decimal  "amount",          precision: 15, scale: 2, default: 0.0
    t.string   "date_bs"
    t.string   "description"
    t.integer  "cheque_entry_id"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  create_table "sales_settlements", force: :cascade do |t|
    t.decimal  "settlement_id",   precision: 18
    t.integer  "status",                         default: 0
    t.date     "settlement_date"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "share_transactions", force: :cascade do |t|
    t.decimal  "contract_no",       precision: 18
    t.integer  "buyer"
    t.integer  "seller"
    t.integer  "quantity"
    t.decimal  "share_rate",        precision: 10, scale: 2, default: 0.0
    t.decimal  "share_amount",      precision: 15, scale: 2, default: 0.0
    t.decimal  "sebo",              precision: 15, scale: 2, default: 0.0
    t.string   "commission_rate"
    t.decimal  "commission_amount", precision: 15, scale: 2, default: 0.0
    t.decimal  "dp_fee",            precision: 15, scale: 2, default: 0.0
    t.decimal  "cgt",               precision: 15, scale: 2, default: 0.0
    t.decimal  "net_amount",        precision: 15, scale: 2, default: 0.0
    t.decimal  "bank_deposit",      precision: 15, scale: 2, default: 0.0
    t.integer  "transaction_type"
    t.decimal  "settlement_id",     precision: 18
    t.decimal  "base_price",        precision: 15, scale: 2, default: 0.0
    t.decimal  "amount_receivable", precision: 15, scale: 2, default: 0.0
    t.decimal  "closeout_amount",   precision: 15, scale: 2, default: 0.0
    t.date     "date"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "bill_id"
    t.integer  "client_account_id"
    t.integer  "isin_info_id"
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
    t.integer  "voucher_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

end
