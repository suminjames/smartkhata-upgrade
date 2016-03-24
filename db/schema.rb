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

ActiveRecord::Schema.define(version: 20160324092710) do

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

  create_table "banks", force: :cascade do |t|
    t.string   "name"
    t.string   "bank_code"
    t.string   "address"
    t.string   "contact_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bills", force: :cascade do |t|
    t.integer  "bill_number"
    t.string   "client_name"
    t.decimal  "net_amount",        precision: 15, scale: 4, default: 0.0
    t.decimal  "balance_to_pay",    precision: 15, scale: 4, default: 0.0
    t.integer  "bill_type"
    t.integer  "status",                                     default: 0
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "fy_code"
    t.integer  "client_account_id"
  end

  add_index "bills", ["client_account_id"], name: "index_bills_on_client_account_id", using: :btree
  add_index "bills", ["fy_code", "bill_number"], name: "index_bills_on_fy_code_and_bill_number", unique: true, using: :btree

  create_table "bills_vouchers", id: false, force: :cascade do |t|
    t.integer "bill_id"
    t.integer "voucher_id"
  end

  add_index "bills_vouchers", ["bill_id"], name: "index_bills_vouchers_on_bill_id", using: :btree
  add_index "bills_vouchers", ["voucher_id"], name: "index_bills_vouchers_on_voucher_id", using: :btree

  create_table "calendars", force: :cascade do |t|
    t.integer  "year",                       null: false
    t.integer  "month",                      null: false
    t.integer  "day",                        null: false
    t.boolean  "is_holiday", default: false
    t.integer  "date_type",                  null: false
    t.text     "remarks"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "cheque_entries", force: :cascade do |t|
    t.integer  "cheque_number"
    t.integer  "bank_account_id"
    t.integer  "particular_id"
    t.integer  "settlement_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "cheque_entries", ["bank_account_id"], name: "index_cheque_entries_on_bank_account_id", using: :btree
  add_index "cheque_entries", ["particular_id"], name: "index_cheque_entries_on_particular_id", using: :btree
  add_index "cheque_entries", ["settlement_id"], name: "index_cheque_entries_on_settlement_id", using: :btree

  create_table "client_accounts", force: :cascade do |t|
    t.string   "boid"
    t.string   "nepse_code"
    t.date     "date"
    t.string   "name"
    t.string   "address1",                  default: " "
    t.string   "address1_perm"
    t.string   "address2",                  default: " "
    t.string   "address2_perm"
    t.string   "address3"
    t.string   "address3_perm"
    t.string   "city",                      default: " "
    t.string   "city_perm"
    t.string   "state"
    t.string   "state_perm"
    t.string   "country",                   default: " "
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
    t.string   "father_mother"
    t.string   "citizen_passport"
    t.string   "granfather_father_inlaw"
    t.string   "purpose_code_add"
    t.string   "add_holder"
    t.string   "husband_spouse"
    t.string   "citizen_passport_date"
    t.string   "citizen_passport_district"
    t.string   "pan_no"
    t.string   "dob_ad"
    t.string   "bank_name"
    t.string   "bank_account"
    t.string   "bank_address"
    t.string   "company_name"
    t.string   "company_id"
    t.boolean  "invited",                   default: false
    t.integer  "user_id"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "client_accounts", ["user_id"], name: "index_client_accounts_on_user_id", using: :btree

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
    t.decimal  "max",        precision: 10, scale: 4, default: 0.0
    t.decimal  "min",        precision: 10, scale: 4, default: 0.0
    t.decimal  "last_price", precision: 10, scale: 4, default: 0.0
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  create_table "ledgers", force: :cascade do |t|
    t.string   "name"
    t.string   "client_code"
    t.decimal  "opening_blnc",      precision: 15, scale: 4, default: 0.0
    t.decimal  "closing_blnc",      precision: 15, scale: 4, default: 0.0
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "group_id"
    t.integer  "bank_account_id"
    t.integer  "client_account_id"
  end

  add_index "ledgers", ["bank_account_id"], name: "index_ledgers_on_bank_account_id", using: :btree
  add_index "ledgers", ["client_account_id"], name: "index_ledgers_on_client_account_id", using: :btree
  add_index "ledgers", ["group_id"], name: "index_ledgers_on_group_id", using: :btree

  create_table "particulars", force: :cascade do |t|
    t.decimal  "opening_blnc",     precision: 15, scale: 4, default: 0.0
    t.integer  "transaction_type"
    t.integer  "cheque_number"
    t.string   "name"
    t.string   "description"
    t.decimal  "amnt",             precision: 15, scale: 4, default: 0.0
    t.decimal  "running_blnc",     precision: 15, scale: 4, default: 0.0
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "ledger_id"
    t.integer  "voucher_id"
  end

  add_index "particulars", ["ledger_id"], name: "index_particulars_on_ledger_id", using: :btree
  add_index "particulars", ["voucher_id"], name: "index_particulars_on_voucher_id", using: :btree

  create_table "sales_settlements", force: :cascade do |t|
    t.decimal  "settlement_id",   precision: 18
    t.integer  "status",                         default: 0
    t.date     "settlement_date"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "settlements", force: :cascade do |t|
    t.string   "name"
    t.decimal  "amount"
    t.string   "date_bs"
    t.string   "description"
    t.integer  "settlement_type"
    t.integer  "fy_code"
    t.integer  "settlement_number"
    t.integer  "voucher_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "settlements", ["fy_code"], name: "index_settlements_on_fy_code", using: :btree
  add_index "settlements", ["settlement_number"], name: "index_settlements_on_settlement_number", using: :btree
  add_index "settlements", ["voucher_id"], name: "index_settlements_on_voucher_id", using: :btree

  create_table "share_transactions", force: :cascade do |t|
    t.decimal  "contract_no",       precision: 18
    t.integer  "buyer"
    t.integer  "seller"
    t.integer  "quantity"
    t.decimal  "share_rate",        precision: 10, scale: 4, default: 0.0
    t.decimal  "share_amount",      precision: 15, scale: 4, default: 0.0
    t.decimal  "sebo",              precision: 15, scale: 4, default: 0.0
    t.string   "commission_rate"
    t.decimal  "commission_amount", precision: 15, scale: 4, default: 0.0
    t.decimal  "dp_fee",            precision: 15, scale: 4, default: 0.0
    t.decimal  "cgt",               precision: 15, scale: 4, default: 0.0
    t.decimal  "net_amount",        precision: 15, scale: 4, default: 0.0
    t.decimal  "bank_deposit",      precision: 15, scale: 4, default: 0.0
    t.integer  "transaction_type"
    t.decimal  "settlement_id",     precision: 18
    t.decimal  "base_price",        precision: 15, scale: 4, default: 0.0
    t.decimal  "amount_receivable", precision: 15, scale: 4, default: 0.0
    t.decimal  "closeout_amount",   precision: 15, scale: 4, default: 0.0
    t.date     "date"
    t.date     "deleted_at"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "bill_id"
    t.integer  "client_account_id"
    t.integer  "isin_info_id"
  end

  add_index "share_transactions", ["bill_id"], name: "index_share_transactions_on_bill_id", using: :btree
  add_index "share_transactions", ["client_account_id"], name: "index_share_transactions_on_client_account_id", using: :btree
  add_index "share_transactions", ["isin_info_id"], name: "index_share_transactions_on_isin_info_id", using: :btree

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
    t.integer  "fy_code"
    t.integer  "voucher_number"
    t.date     "date"
    t.string   "date_bs"
    t.string   "desc"
    t.integer  "voucher_type",   default: 0
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "vouchers", ["fy_code", "voucher_number", "voucher_type"], name: "index_vouchers_on_fy_code_and_voucher_number_and_voucher_type", unique: true, using: :btree

  add_foreign_key "settlements", "vouchers"
end
