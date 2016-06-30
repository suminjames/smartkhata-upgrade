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

ActiveRecord::Schema.define(version: 20160629103546) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bank_accounts", force: :cascade do |t|
    t.string   "account_number"
    t.string   "bank_name"
    t.boolean  "default_for_payment"
    t.boolean  "default_for_receipt"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "bank_id"
  end

  add_index "bank_accounts", ["bank_id"], name: "index_bank_accounts_on_bank_id", using: :btree
  add_index "bank_accounts", ["creator_id"], name: "index_bank_accounts_on_creator_id", using: :btree
  add_index "bank_accounts", ["updater_id"], name: "index_bank_accounts_on_updater_id", using: :btree

  create_table "banks", force: :cascade do |t|
    t.string   "name"
    t.string   "bank_code"
    t.string   "address"
    t.string   "contact_no"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "banks", ["creator_id"], name: "index_banks_on_creator_id", using: :btree
  add_index "banks", ["updater_id"], name: "index_banks_on_updater_id", using: :btree

  create_table "bill_voucher_associations", force: :cascade do |t|
    t.integer  "association_type"
    t.integer  "bill_id"
    t.integer  "voucher_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "bill_voucher_associations", ["bill_id"], name: "index_bill_voucher_associations_on_bill_id", using: :btree
  add_index "bill_voucher_associations", ["voucher_id"], name: "index_bill_voucher_associations_on_voucher_id", using: :btree

  create_table "bills", force: :cascade do |t|
    t.integer  "bill_number"
    t.string   "client_name"
    t.decimal  "net_amount",        precision: 15, scale: 4, default: 0.0
    t.decimal  "balance_to_pay",    precision: 15, scale: 4, default: 0.0
    t.integer  "bill_type"
    t.integer  "status",                                     default: 0
    t.integer  "special_case",                               default: 0
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.integer  "fy_code"
    t.date     "date"
    t.string   "date_bs"
    t.date     "settlement_date"
    t.integer  "client_account_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "branch_id"
  end

  add_index "bills", ["branch_id"], name: "index_bills_on_branch_id", using: :btree
  add_index "bills", ["client_account_id"], name: "index_bills_on_client_account_id", using: :btree
  add_index "bills", ["creator_id"], name: "index_bills_on_creator_id", using: :btree
  add_index "bills", ["date"], name: "index_bills_on_date", using: :btree
  add_index "bills", ["fy_code", "bill_number"], name: "index_bills_on_fy_code_and_bill_number", unique: true, using: :btree
  add_index "bills", ["fy_code"], name: "index_bills_on_fy_code", using: :btree
  add_index "bills", ["updater_id"], name: "index_bills_on_updater_id", using: :btree

  create_table "branches", force: :cascade do |t|
    t.string   "code"
    t.string   "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "calendars", force: :cascade do |t|
    t.text     "bs_date",                        null: false
    t.date     "ad_date",                        null: false
    t.boolean  "is_holiday",     default: false
    t.boolean  "is_trading_day", default: true
    t.integer  "holiday_type",   default: 0
    t.text     "remarks"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "calendars", ["creator_id"], name: "index_calendars_on_creator_id", using: :btree
  add_index "calendars", ["updater_id"], name: "index_calendars_on_updater_id", using: :btree

  create_table "cheque_entries", force: :cascade do |t|
    t.string   "beneficiary_name"
    t.integer  "cheque_number"
    t.integer  "additional_bank_id"
    t.integer  "status",                                      default: 0
    t.integer  "print_status",                                default: 0
    t.integer  "cheque_issued_type",                          default: 0
    t.date     "cheque_date"
    t.decimal  "amount",             precision: 15, scale: 4, default: 0.0
    t.integer  "bank_account_id"
    t.integer  "client_account_id"
    t.integer  "vendor_account_id"
    t.integer  "settlement_id"
    t.integer  "voucher_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "branch_id"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.integer  "fy_code"
  end

  add_index "cheque_entries", ["bank_account_id"], name: "index_cheque_entries_on_bank_account_id", using: :btree
  add_index "cheque_entries", ["branch_id"], name: "index_cheque_entries_on_branch_id", using: :btree
  add_index "cheque_entries", ["client_account_id"], name: "index_cheque_entries_on_client_account_id", using: :btree
  add_index "cheque_entries", ["creator_id"], name: "index_cheque_entries_on_creator_id", using: :btree
  add_index "cheque_entries", ["settlement_id"], name: "index_cheque_entries_on_settlement_id", using: :btree
  add_index "cheque_entries", ["updater_id"], name: "index_cheque_entries_on_updater_id", using: :btree
  add_index "cheque_entries", ["vendor_account_id"], name: "index_cheque_entries_on_vendor_account_id", using: :btree
  add_index "cheque_entries", ["voucher_id"], name: "index_cheque_entries_on_voucher_id", using: :btree

  create_table "cheque_entry_particular_associations", force: :cascade do |t|
    t.integer  "association_type"
    t.integer  "cheque_entry_id"
    t.integer  "particular_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "cheque_entry_particular_associations", ["cheque_entry_id"], name: "index_cheque_entry_particular_associations_on_cheque_entry_id", using: :btree
  add_index "cheque_entry_particular_associations", ["particular_id"], name: "index_cheque_entry_particular_associations_on_particular_id", using: :btree

  create_table "client_accounts", force: :cascade do |t|
    t.string   "boid"
    t.string   "nepse_code"
    t.integer  "client_type",               default: 0
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
    t.string   "company_address"
    t.string   "company_id"
    t.boolean  "invited",                   default: false
    t.string   "referrer_name"
    t.integer  "group_leader_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "branch_id"
    t.integer  "user_id"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "mobile_number"
    t.string   "ac_code"
  end

  add_index "client_accounts", ["branch_id"], name: "index_client_accounts_on_branch_id", using: :btree
  add_index "client_accounts", ["creator_id"], name: "index_client_accounts_on_creator_id", using: :btree
  add_index "client_accounts", ["group_leader_id"], name: "index_client_accounts_on_group_leader_id", using: :btree
  add_index "client_accounts", ["updater_id"], name: "index_client_accounts_on_updater_id", using: :btree
  add_index "client_accounts", ["user_id"], name: "index_client_accounts_on_user_id", using: :btree

  create_table "closeouts", force: :cascade do |t|
    t.decimal  "settlement_id",     precision: 18
    t.decimal  "contract_number",   precision: 18
    t.integer  "seller_cm"
    t.string   "seller_client"
    t.integer  "buyer_cm"
    t.string   "buyer_client"
    t.string   "isin"
    t.string   "scrip_name"
    t.integer  "quantity"
    t.integer  "shortage_quantity"
    t.decimal  "rate",              precision: 15, scale: 4, default: 0.0
    t.decimal  "net_amount",        precision: 15, scale: 4, default: 0.0
    t.integer  "closeout_type"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "branch_id"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  add_index "closeouts", ["branch_id"], name: "index_closeouts_on_branch_id", using: :btree
  add_index "closeouts", ["creator_id"], name: "index_closeouts_on_creator_id", using: :btree
  add_index "closeouts", ["updater_id"], name: "index_closeouts_on_updater_id", using: :btree

  create_table "employee_accounts", force: :cascade do |t|
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
    t.string   "dob"
    t.string   "sex"
    t.string   "nationality"
    t.string   "email"
    t.string   "father_mother"
    t.string   "citizen_passport"
    t.string   "granfather_father_inlaw"
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
    t.integer  "branch_id"
    t.boolean  "invited",                   default: false
    t.integer  "has_access_to",             default: 2
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "user_id"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "employee_accounts", ["branch_id"], name: "index_employee_accounts_on_branch_id", using: :btree
  add_index "employee_accounts", ["creator_id"], name: "index_employee_accounts_on_creator_id", using: :btree
  add_index "employee_accounts", ["updater_id"], name: "index_employee_accounts_on_updater_id", using: :btree
  add_index "employee_accounts", ["user_id"], name: "index_employee_accounts_on_user_id", using: :btree

  create_table "employee_ledger_associations", force: :cascade do |t|
    t.integer  "employee_account_id"
    t.integer  "ledger_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "employee_ledger_associations", ["creator_id"], name: "index_employee_ledger_associations_on_creator_id", using: :btree
  add_index "employee_ledger_associations", ["employee_account_id"], name: "index_employee_ledger_associations_on_employee_account_id", using: :btree
  add_index "employee_ledger_associations", ["ledger_id"], name: "index_employee_ledger_associations_on_ledger_id", using: :btree
  add_index "employee_ledger_associations", ["updater_id"], name: "index_employee_ledger_associations_on_updater_id", using: :btree

  create_table "file_uploads", force: :cascade do |t|
    t.integer  "file_type"
    t.date     "report_date"
    t.boolean  "ignore",      default: false
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "branch_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "file_uploads", ["branch_id"], name: "index_file_uploads_on_branch_id", using: :btree
  add_index "file_uploads", ["creator_id"], name: "index_file_uploads_on_creator_id", using: :btree
  add_index "file_uploads", ["updater_id"], name: "index_file_uploads_on_updater_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "report"
    t.integer  "sub_report"
    t.boolean  "for_trial_balance", default: false
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "groups", ["creator_id"], name: "index_groups_on_creator_id", using: :btree
  add_index "groups", ["updater_id"], name: "index_groups_on_updater_id", using: :btree

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

  create_table "ledger_dailies", force: :cascade do |t|
    t.date     "date"
    t.decimal  "dr_amount",    precision: 15, scale: 4, default: 0.0
    t.decimal  "cr_amount",    precision: 15, scale: 4, default: 0.0
    t.decimal  "opening_blnc", precision: 15, scale: 4, default: 0.0
    t.decimal  "closing_blnc", precision: 15, scale: 4, default: 0.0
    t.string   "date_bs"
    t.integer  "fy_code"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "ledger_id"
    t.integer  "branch_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "ledger_dailies", ["branch_id"], name: "index_ledger_dailies_on_branch_id", using: :btree
  add_index "ledger_dailies", ["creator_id"], name: "index_ledger_dailies_on_creator_id", using: :btree
  add_index "ledger_dailies", ["fy_code"], name: "index_ledger_dailies_on_fy_code", using: :btree
  add_index "ledger_dailies", ["ledger_id"], name: "index_ledger_dailies_on_ledger_id", using: :btree
  add_index "ledger_dailies", ["updater_id"], name: "index_ledger_dailies_on_updater_id", using: :btree

  create_table "ledgers", force: :cascade do |t|
    t.string   "name"
    t.string   "client_code"
    t.decimal  "opening_blnc",        precision: 15, scale: 4, default: 0.0
    t.decimal  "closing_blnc",        precision: 15, scale: 4, default: 0.0
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "fy_code"
    t.integer  "branch_id"
    t.decimal  "dr_amount",           precision: 15, scale: 4, default: 0.0, null: false
    t.decimal  "cr_amount",           precision: 15, scale: 4, default: 0.0, null: false
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.integer  "group_id"
    t.integer  "bank_account_id"
    t.integer  "client_account_id"
    t.integer  "employee_account_id"
    t.integer  "vendor_account_id"
  end

  add_index "ledgers", ["bank_account_id"], name: "index_ledgers_on_bank_account_id", using: :btree
  add_index "ledgers", ["branch_id"], name: "index_ledgers_on_branch_id", using: :btree
  add_index "ledgers", ["client_account_id"], name: "index_ledgers_on_client_account_id", using: :btree
  add_index "ledgers", ["creator_id"], name: "index_ledgers_on_creator_id", using: :btree
  add_index "ledgers", ["employee_account_id"], name: "index_ledgers_on_employee_account_id", using: :btree
  add_index "ledgers", ["fy_code"], name: "index_ledgers_on_fy_code", using: :btree
  add_index "ledgers", ["group_id"], name: "index_ledgers_on_group_id", using: :btree
  add_index "ledgers", ["updater_id"], name: "index_ledgers_on_updater_id", using: :btree
  add_index "ledgers", ["vendor_account_id"], name: "index_ledgers_on_vendor_account_id", using: :btree

  create_table "menu_items", force: :cascade do |t|
    t.string   "name"
    t.string   "path"
    t.boolean  "hide_on_main_navigation", default: false
    t.integer  "request_type",            default: 0
    t.string   "code"
    t.string   "ancestry"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "menu_items", ["ancestry"], name: "index_menu_items_on_ancestry", using: :btree

  create_table "menu_permissions", force: :cascade do |t|
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "menu_item_id"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "menu_permissions", ["creator_id"], name: "index_menu_permissions_on_creator_id", using: :btree
  add_index "menu_permissions", ["menu_item_id"], name: "index_menu_permissions_on_menu_item_id", using: :btree
  add_index "menu_permissions", ["updater_id"], name: "index_menu_permissions_on_updater_id", using: :btree
  add_index "menu_permissions", ["user_id"], name: "index_menu_permissions_on_user_id", using: :btree

  create_table "nepse_chalans", force: :cascade do |t|
    t.decimal  "chalan_amount",       precision: 15, scale: 4, default: 0.0
    t.integer  "transaction_type"
    t.string   "deposited_date_bs"
    t.date     "deposited_date"
    t.string   "nepse_settlement_id"
    t.integer  "voucher_id"
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "fy_code"
    t.integer  "branch_id"
  end

  add_index "nepse_chalans", ["branch_id"], name: "index_nepse_chalans_on_branch_id", using: :btree
  add_index "nepse_chalans", ["creator_id"], name: "index_nepse_chalans_on_creator_id", using: :btree
  add_index "nepse_chalans", ["fy_code"], name: "index_nepse_chalans_on_fy_code", using: :btree
  add_index "nepse_chalans", ["updater_id"], name: "index_nepse_chalans_on_updater_id", using: :btree
  add_index "nepse_chalans", ["voucher_id"], name: "index_nepse_chalans_on_voucher_id", using: :btree

  create_table "order_details", force: :cascade do |t|
    t.integer  "order_id"
    t.string   "order_nepse_id"
    t.integer  "isin_info_id"
    t.decimal  "price"
    t.integer  "quantity"
    t.decimal  "amount"
    t.integer  "pending_quantity"
    t.integer  "typee"
    t.integer  "segment"
    t.integer  "condition"
    t.integer  "state"
    t.datetime "date_time"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "order_details", ["isin_info_id"], name: "index_order_details_on_isin_info_id", using: :btree
  add_index "order_details", ["order_id"], name: "index_order_details_on_order_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "order_number"
    t.integer  "client_account_id"
    t.integer  "fy_code"
    t.date     "date"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "orders", ["client_account_id"], name: "index_orders_on_client_account_id", using: :btree

  create_table "particulars", force: :cascade do |t|
    t.decimal  "opening_blnc",       precision: 15, scale: 4, default: 0.0
    t.integer  "transaction_type"
    t.integer  "ledger_type",                                 default: 0
    t.integer  "cheque_number"
    t.string   "name"
    t.string   "description"
    t.decimal  "amount",             precision: 15, scale: 4, default: 0.0
    t.decimal  "running_blnc",       precision: 15, scale: 4, default: 0.0
    t.integer  "additional_bank_id"
    t.integer  "particular_status",                           default: 1
    t.string   "date_bs"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "fy_code"
    t.integer  "branch_id"
    t.date     "transaction_date"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.integer  "ledger_id"
    t.integer  "voucher_id"
  end

  add_index "particulars", ["branch_id"], name: "index_particulars_on_branch_id", using: :btree
  add_index "particulars", ["creator_id"], name: "index_particulars_on_creator_id", using: :btree
  add_index "particulars", ["fy_code"], name: "index_particulars_on_fy_code", using: :btree
  add_index "particulars", ["ledger_id"], name: "index_particulars_on_ledger_id", using: :btree
  add_index "particulars", ["updater_id"], name: "index_particulars_on_updater_id", using: :btree
  add_index "particulars", ["voucher_id"], name: "index_particulars_on_voucher_id", using: :btree

  create_table "sales_settlements", force: :cascade do |t|
    t.decimal  "settlement_id",   precision: 18
    t.integer  "status",                         default: 0
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.date     "settlement_date"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "sales_settlements", ["creator_id"], name: "index_sales_settlements_on_creator_id", using: :btree
  add_index "sales_settlements", ["updater_id"], name: "index_sales_settlements_on_updater_id", using: :btree

  create_table "settlements", force: :cascade do |t|
    t.string   "name"
    t.decimal  "amount"
    t.string   "date_bs"
    t.string   "description"
    t.integer  "settlement_type"
    t.integer  "fy_code"
    t.integer  "settlement_number"
    t.integer  "client_account_id"
    t.integer  "vendor_account_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.string   "receiver_name"
    t.integer  "voucher_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "branch_id"
  end

  add_index "settlements", ["client_account_id"], name: "index_settlements_on_client_account_id", using: :btree
  add_index "settlements", ["creator_id"], name: "index_settlements_on_creator_id", using: :btree
  add_index "settlements", ["fy_code"], name: "index_settlements_on_fy_code", using: :btree
  add_index "settlements", ["settlement_number"], name: "index_settlements_on_settlement_number", using: :btree
  add_index "settlements", ["updater_id"], name: "index_settlements_on_updater_id", using: :btree
  add_index "settlements", ["vendor_account_id"], name: "index_settlements_on_vendor_account_id", using: :btree
  add_index "settlements", ["voucher_id"], name: "index_settlements_on_voucher_id", using: :btree

  create_table "share_inventories", force: :cascade do |t|
    t.string   "isin_desc"
    t.decimal  "current_blnc",      precision: 10, scale: 3, default: 0.0
    t.decimal  "free_blnc",         precision: 10, scale: 3, default: 0.0
    t.decimal  "freeze_blnc",       precision: 10, scale: 3, default: 0.0
    t.decimal  "dmt_pending_veri",  precision: 10, scale: 3, default: 0.0
    t.decimal  "dmt_pending_conf",  precision: 10, scale: 3, default: 0.0
    t.decimal  "rmt_pending_conf",  precision: 10, scale: 3, default: 0.0
    t.decimal  "safe_keep_blnc",    precision: 10, scale: 3, default: 0.0
    t.decimal  "lock_blnc",         precision: 10, scale: 3, default: 0.0
    t.decimal  "earmark_blnc",      precision: 10, scale: 3, default: 0.0
    t.decimal  "elimination_blnc",  precision: 10, scale: 3, default: 0.0
    t.decimal  "avl_lend_blnc",     precision: 10, scale: 3, default: 0.0
    t.decimal  "lend_blnc",         precision: 10, scale: 3, default: 0.0
    t.decimal  "borrow_blnc",       precision: 10, scale: 3, default: 0.0
    t.decimal  "pledge_blnc",       precision: 10, scale: 3, default: 0.0
    t.decimal  "total_in",          precision: 10,           default: 0
    t.decimal  "total_out",         precision: 10,           default: 0
    t.decimal  "floorsheet_blnc",   precision: 10,           default: 0
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "branch_id"
    t.date     "report_date"
    t.integer  "client_account_id"
    t.integer  "isin_info_id"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  add_index "share_inventories", ["branch_id"], name: "index_share_inventories_on_branch_id", using: :btree
  add_index "share_inventories", ["client_account_id"], name: "index_share_inventories_on_client_account_id", using: :btree
  add_index "share_inventories", ["creator_id"], name: "index_share_inventories_on_creator_id", using: :btree
  add_index "share_inventories", ["isin_info_id"], name: "index_share_inventories_on_isin_info_id", using: :btree
  add_index "share_inventories", ["updater_id"], name: "index_share_inventories_on_updater_id", using: :btree

  create_table "share_transactions", force: :cascade do |t|
    t.decimal  "contract_no",               precision: 18
    t.integer  "buyer"
    t.integer  "seller"
    t.integer  "raw_quantity"
    t.integer  "quantity"
    t.decimal  "share_rate",                precision: 10, scale: 4, default: 0.0
    t.decimal  "share_amount",              precision: 15, scale: 4, default: 0.0
    t.decimal  "sebo",                      precision: 15, scale: 4, default: 0.0
    t.string   "commission_rate"
    t.decimal  "commission_amount",         precision: 15, scale: 4, default: 0.0
    t.decimal  "dp_fee",                    precision: 15, scale: 4, default: 0.0
    t.decimal  "cgt",                       precision: 15, scale: 4, default: 0.0
    t.decimal  "net_amount",                precision: 15, scale: 4, default: 0.0
    t.decimal  "bank_deposit",              precision: 15, scale: 4, default: 0.0
    t.integer  "transaction_type"
    t.decimal  "settlement_id",             precision: 18
    t.decimal  "base_price",                precision: 15, scale: 4, default: 0.0
    t.decimal  "amount_receivable",         precision: 15, scale: 4, default: 0.0
    t.decimal  "closeout_amount",           precision: 15, scale: 4, default: 0.0
    t.string   "remarks"
    t.decimal  "purchase_price",            precision: 15, scale: 4, default: 0.0
    t.decimal  "capital_gain",              precision: 15, scale: 4, default: 0.0
    t.decimal  "adjusted_sell_price",       precision: 15, scale: 4, default: 0.0
    t.date     "date"
    t.date     "deleted_at"
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.integer  "nepse_chalan_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "branch_id"
    t.integer  "voucher_id"
    t.integer  "bill_id"
    t.integer  "client_account_id"
    t.integer  "isin_info_id"
    t.integer  "transaction_message_id"
    t.integer  "transaction_cancel_status",                          default: 0
  end

  add_index "share_transactions", ["bill_id"], name: "index_share_transactions_on_bill_id", using: :btree
  add_index "share_transactions", ["branch_id"], name: "index_share_transactions_on_branch_id", using: :btree
  add_index "share_transactions", ["client_account_id"], name: "index_share_transactions_on_client_account_id", using: :btree
  add_index "share_transactions", ["creator_id"], name: "index_share_transactions_on_creator_id", using: :btree
  add_index "share_transactions", ["isin_info_id"], name: "index_share_transactions_on_isin_info_id", using: :btree
  add_index "share_transactions", ["nepse_chalan_id"], name: "index_share_transactions_on_nepse_chalan_id", using: :btree
  add_index "share_transactions", ["updater_id"], name: "index_share_transactions_on_updater_id", using: :btree
  add_index "share_transactions", ["voucher_id"], name: "index_share_transactions_on_voucher_id", using: :btree

  create_table "sms_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tenants", force: :cascade do |t|
    t.string   "name"
    t.string   "dp_id"
    t.string   "full_name"
    t.string   "phone_number"
    t.string   "address"
    t.string   "pan_number"
    t.string   "fax_number"
    t.string   "broker_code"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "transaction_messages", force: :cascade do |t|
    t.string   "sms_message"
    t.date     "transaction_date"
    t.integer  "sms_status",        default: 0
    t.integer  "email_status",      default: 0
    t.string   "remarks"
    t.integer  "bill_id"
    t.integer  "client_account_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.date     "deleted_at"
    t.integer  "sent_sms_count",    default: 5
    t.integer  "sent_email_count",  default: 5
  end

  add_index "transaction_messages", ["bill_id"], name: "index_transaction_messages_on_bill_id", using: :btree
  add_index "transaction_messages", ["client_account_id"], name: "index_transaction_messages_on_client_account_id", using: :btree

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
    t.integer  "branch_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vendor_accounts", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "phone_number"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "branch_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "vendor_accounts", ["branch_id"], name: "index_vendor_accounts_on_branch_id", using: :btree
  add_index "vendor_accounts", ["creator_id"], name: "index_vendor_accounts_on_creator_id", using: :btree
  add_index "vendor_accounts", ["updater_id"], name: "index_vendor_accounts_on_updater_id", using: :btree

  create_table "vouchers", force: :cascade do |t|
    t.integer  "fy_code"
    t.integer  "voucher_number"
    t.date     "date"
    t.string   "date_bs"
    t.string   "desc"
    t.string   "beneficiary_name"
    t.integer  "voucher_type",     default: 0
    t.integer  "voucher_status",   default: 0
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "reviewer_id"
    t.integer  "branch_id"
    t.boolean  "is_payment_bank"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "vouchers", ["branch_id"], name: "index_vouchers_on_branch_id", using: :btree
  add_index "vouchers", ["creator_id"], name: "index_vouchers_on_creator_id", using: :btree
  add_index "vouchers", ["fy_code", "voucher_number", "voucher_type"], name: "index_vouchers_on_fy_code_and_voucher_number_and_voucher_type", unique: true, using: :btree
  add_index "vouchers", ["fy_code"], name: "index_vouchers_on_fy_code", using: :btree
  add_index "vouchers", ["reviewer_id"], name: "index_vouchers_on_reviewer_id", using: :btree
  add_index "vouchers", ["updater_id"], name: "index_vouchers_on_updater_id", using: :btree

  add_foreign_key "bill_voucher_associations", "bills"
  add_foreign_key "bill_voucher_associations", "vouchers"
  add_foreign_key "cheque_entry_particular_associations", "cheque_entries"
  add_foreign_key "cheque_entry_particular_associations", "particulars"
  add_foreign_key "menu_permissions", "menu_items"
  add_foreign_key "nepse_chalans", "vouchers"
  add_foreign_key "settlements", "vouchers"
  add_foreign_key "transaction_messages", "client_accounts"
end
