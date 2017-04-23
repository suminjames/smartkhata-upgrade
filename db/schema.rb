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

ActiveRecord::Schema.define(version: 20170413081703) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_balance", force: :cascade do |t|
    t.string "ac_code"
    t.string "sub_code"
    t.string "balance_amount"
    t.string "balance_date"
    t.string "fiscal_year"
    t.string "balance_type"
    t.string "nrs_balance_amount"
    t.string "closed_by"
    t.string "closed_date"
  end

  create_table "agm", force: :cascade do |t|
    t.string "company_code"
    t.string "agm_date"
    t.string "book_close_date"
    t.string "agm_place"
    t.string "divident_pct"
    t.string "bonus_pct"
    t.string "right_share"
    t.string "fiscal_year"
  end

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

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
    t.integer  "branch_id"
    t.string   "bank_branch"
    t.text     "address"
    t.string   "contact_no"
  end

  add_index "bank_accounts", ["bank_id"], name: "index_bank_accounts_on_bank_id", using: :btree
  add_index "bank_accounts", ["creator_id"], name: "index_bank_accounts_on_creator_id", using: :btree
  add_index "bank_accounts", ["updater_id"], name: "index_bank_accounts_on_updater_id", using: :btree

  create_table "bank_code", force: :cascade do |t|
    t.string "bank_code"
    t.string "bank_name"
    t.string "ac_code"
    t.string "remarks"
  end

  create_table "bank_parameter", force: :cascade do |t|
    t.string "bank_code"
    t.string "bank_name"
    t.string "ac_code"
    t.string "remarks"
  end

  create_table "bank_payment_letters", force: :cascade do |t|
    t.decimal  "settlement_amount",             precision: 15, scale: 4, default: 0.0
    t.integer  "fy_code"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "bank_account_id"
    t.integer  "nepse_settlement_id", limit: 8
    t.integer  "branch_id"
    t.integer  "voucher_id"
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.integer  "letter_status",                                          default: 0
    t.integer  "reviewer_id",                                            default: 0
  end

  add_index "bank_payment_letters", ["bank_account_id"], name: "index_bank_payment_letters_on_bank_account_id", using: :btree
  add_index "bank_payment_letters", ["branch_id"], name: "index_bank_payment_letters_on_branch_id", using: :btree
  add_index "bank_payment_letters", ["nepse_settlement_id"], name: "index_bank_payment_letters_on_nepse_settlement_id", using: :btree
  add_index "bank_payment_letters", ["voucher_id"], name: "index_bank_payment_letters_on_voucher_id", using: :btree

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

  create_table "bill", force: :cascade do |t|
    t.string  "bill_no"
    t.string  "bill_date"
    t.string  "bill_type"
    t.string  "clearance_date"
    t.string  "customer_code"
    t.string  "bill_bs_date"
    t.string  "clearance_bs_date"
    t.string  "vendor_id"
    t.string  "bill_status"
    t.string  "voucher_no"
    t.string  "voucher_code"
    t.string  "bill_transaction_type"
    t.string  "chalan_no"
    t.string  "chalan_form_no"
    t.string  "group_code"
    t.string  "transaction_date"
    t.string  "cust_type"
    t.string  "cr_customer_code"
    t.string  "bill_reverse"
    t.string  "mutual_tag"
    t.string  "mutual_no"
    t.string  "fiscal_year"
    t.string  "transaction_fee"
    t.string  "settlement_tag"
    t.string  "net_rev_amt"
    t.string  "net_pay_amt"
    t.string  "total_demat_amount"
    t.string  "total_nt_amount"
    t.integer "bill_id"
    t.date    "bill_date_parsed"
  end

  add_index "bill", ["bill_no"], name: "index_bill_on_bill_no", using: :btree

  create_table "bill_detail", force: :cascade do |t|
    t.string "bill_no"
    t.string "no_of_shares"
    t.string "company_code"
    t.string "rate_per_share"
    t.string "amount"
    t.string "commission_rate"
    t.string "commission_amount"
    t.string "budget_code"
    t.string "item_name"
    t.string "item_rate"
    t.string "transaction_no"
    t.string "share_code"
    t.string "capital_gain"
    t.string "name_transfer_rate"
    t.string "base_price"
    t.string "mutual_capital_gain"
    t.string "fiscal_year"
    t.string "transaction_fee"
    t.string "transaction_type"
    t.string "demat_rate"
    t.string "no_of_shortage_shares"
    t.string "close_out_amount"
  end

  add_index "bill_detail", ["bill_no"], name: "index_bill_detail_on_bill_no", using: :btree
  add_index "bill_detail", ["transaction_no"], name: "index_bill_detail_on_transaction_no", using: :btree
  add_index "bill_detail", ["transaction_type"], name: "index_bill_detail_on_transaction_type", using: :btree

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
    t.decimal  "net_amount",                           precision: 15, scale: 4, default: 0.0
    t.decimal  "balance_to_pay",                       precision: 15, scale: 4, default: 0.0
    t.integer  "bill_type"
    t.integer  "status",                                                        default: 0
    t.integer  "special_case",                                                  default: 0
    t.datetime "created_at",                                                                  null: false
    t.datetime "updated_at",                                                                  null: false
    t.integer  "fy_code"
    t.date     "date"
    t.string   "date_bs"
    t.date     "settlement_date"
    t.integer  "client_account_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "branch_id"
    t.integer  "nepse_settlement_id",        limit: 8
    t.integer  "settlement_approval_status",                                    default: 0
    t.decimal  "closeout_charge",                      precision: 15, scale: 4, default: 0.0
  end

  add_index "bills", ["branch_id"], name: "index_bills_on_branch_id", using: :btree
  add_index "bills", ["client_account_id"], name: "index_bills_on_client_account_id", using: :btree
  add_index "bills", ["creator_id"], name: "index_bills_on_creator_id", using: :btree
  add_index "bills", ["date"], name: "index_bills_on_date", using: :btree
  add_index "bills", ["fy_code", "bill_number"], name: "index_bills_on_fy_code_and_bill_number", unique: true, using: :btree
  add_index "bills", ["fy_code"], name: "index_bills_on_fy_code", using: :btree
  add_index "bills", ["updater_id"], name: "index_bills_on_updater_id", using: :btree

  create_table "branch_permissions", force: :cascade do |t|
    t.integer  "branch_id"
    t.integer  "user_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "branches", force: :cascade do |t|
    t.string   "code"
    t.string   "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "broker_parameter", force: :cascade do |t|
    t.string "org_name"
    t.string "org_address"
    t.string "contact_person"
    t.string "broker_no"
    t.string "off_tel_no"
    t.string "res_tel_no"
    t.string "fax"
    t.string "mobile"
  end

  create_table "broker_profiles", force: :cascade do |t|
    t.string   "broker_name"
    t.string   "broker_number"
    t.string   "address"
    t.integer  "dp_code"
    t.string   "phone_number"
    t.string   "fax_number"
    t.string   "email"
    t.string   "pan_number"
    t.integer  "profile_type"
    t.integer  "locale"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "broker_profiles", ["profile_type"], name: "index_broker_profiles_on_profile_type", using: :btree

  create_table "buy_settlement", force: :cascade do |t|
    t.string "transaction_no"
    t.string "transaction_type"
    t.string "transaction_date"
    t.string "company_code"
    t.string "quantity"
    t.string "rate"
    t.string "nepse_commission"
    t.string "sebo_commission"
    t.string "tds"
    t.string "settlement_id"
  end

  create_table "calendar_parameter", force: :cascade do |t|
    t.string "ad_date"
    t.string "bs_date"
    t.string "holiday_tag"
    t.string "day"
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

  create_table "capital_gain_detail", force: :cascade do |t|
    t.string "group_code"
    t.string "capital_gain_pct"
    t.string "effective_from"
    t.string "effective_to"
  end

  create_table "capital_gain_para", force: :cascade do |t|
    t.string "group_code"
    t.string "group_name"
    t.string "remarks"
  end

  create_table "chart_of_account", force: :cascade do |t|
    t.string  "ac_code"
    t.string  "sub_code"
    t.string  "ac_name"
    t.string  "account_type"
    t.string  "currency_code"
    t.string  "control_account"
    t.string  "sub_ledger"
    t.string  "reporting_group"
    t.string  "mgr_ac_code"
    t.string  "mgr_sub_code"
    t.string  "fiscal_year"
    t.integer "ledger_id"
    t.integer "group_id"
  end

  add_index "chart_of_account", ["ac_code"], name: "index_chart_of_account_on_ac_code", using: :btree
  add_index "chart_of_account", ["account_type"], name: "index_chart_of_account_on_account_type", using: :btree

  create_table "cheque_entries", force: :cascade do |t|
    t.string   "beneficiary_name"
    t.integer  "cheque_number",      limit: 8
    t.integer  "additional_bank_id"
    t.integer  "status",                                                default: 0
    t.integer  "print_status",                                          default: 0
    t.integer  "cheque_issued_type",                                    default: 0
    t.date     "cheque_date"
    t.decimal  "amount",                       precision: 15, scale: 4, default: 0.0
    t.integer  "bank_account_id"
    t.integer  "client_account_id"
    t.integer  "vendor_account_id"
    t.integer  "settlement_id"
    t.integer  "voucher_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "branch_id"
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.integer  "fy_code"
    t.date     "bounce_date"
    t.text     "bounce_narration"
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
    t.integer "association_type"
    t.integer "cheque_entry_id"
    t.integer "particular_id"
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

  create_table "commission", force: :cascade do |t|
    t.string "un_id"
    t.string "effective_date_from"
    t.string "effective_date_to"
  end

  create_table "commission_rate", force: :cascade do |t|
    t.string "un_id"
    t.string "amount_below"
    t.string "amount_above"
    t.string "rate"
    t.string "commission_amount"
  end

  create_table "company_parameter", force: :cascade do |t|
    t.string  "company_code"
    t.string  "nepse_code"
    t.string  "company_name"
    t.string  "sector_code"
    t.string  "listing_date"
    t.string  "incorpyear"
    t.string  "company_address"
    t.string  "listing_bs_date"
    t.string  "no_of_share",     limit: 8
    t.string  "demat"
    t.integer "isin_info_id"
  end

  add_index "company_parameter", ["company_code"], name: "index_company_parameter_on_company_code", using: :btree

  create_table "company_parameter_list", force: :cascade do |t|
    t.string "company_code"
    t.string "share_code"
    t.string "no_of_shares"
    t.string "share_no_from"
    t.string "share_no_to"
    t.string "par_value_share"
    t.string "paid_value_share"
  end

  create_table "customer_child_info", force: :cascade do |t|
    t.string "customer_code"
    t.string "child_name"
    t.string "relation"
    t.string "child_dob"
    t.string "child_dob_bs"
    t.string "child_birth_reg_no"
    t.string "issued_place"
  end

  create_table "customer_ledger", force: :cascade do |t|
    t.string "customer_code"
    t.string "bill_no"
    t.string "settlement_date"
    t.string "particulars"
    t.string "entered_by"
    t.string "entered_date"
    t.string "fiscal_year"
    t.string "transaction_date"
    t.string "dr_amount"
    t.string "cr_amount"
    t.string "remarks"
    t.string "transaction_id"
    t.string "slip_no"
    t.string "slip_type"
    t.string "bill_type"
    t.string "settlement_tag"
  end

  create_table "customer_registration", force: :cascade do |t|
    t.string  "customer_code"
    t.string  "customer_name"
    t.string  "fathers_name"
    t.string  "g_father_name"
    t.string  "citizenship_no"
    t.string  "tel_no"
    t.string  "fax"
    t.string  "email"
    t.string  "contact_person"
    t.string  "customer_address"
    t.string  "mgr_ac_code"
    t.string  "ac_code"
    t.string  "group_tag"
    t.string  "group_code"
    t.string  "dob"
    t.string  "dob_bs"
    t.string  "birth_reg_no"
    t.string  "birth_reg_issued_date"
    t.string  "ctznp_issued_date"
    t.string  "ctznp_issued_date_bs"
    t.string  "ctznp_issued_district_code"
    t.string  "pan_no"
    t.string  "husband_wife_name"
    t.string  "occupation"
    t.string  "organization_name"
    t.string  "organization_address"
    t.string  "idcard_no"
    t.string  "mobile_no"
    t.string  "skype_id"
    t.string  "temp_district_code"
    t.string  "temp_vdc_mp_smp"
    t.string  "temp_vdc_mp_smp_name"
    t.string  "temp_tole"
    t.string  "temp_ward_no"
    t.string  "temp_block_no"
    t.string  "per_district_code"
    t.string  "per_vdc_mp_smp"
    t.string  "per_vdc_mp_smp_name"
    t.string  "per_tole"
    t.string  "per_ward_no"
    t.string  "per_block_no"
    t.string  "per_tel_no"
    t.string  "per_fax_no"
    t.string  "financial_institution_name"
    t.string  "financial_institution_address"
    t.string  "account_no"
    t.string  "company_reg_no"
    t.string  "company_reg_date"
    t.string  "company_reg_date_bs"
    t.string  "business_sector"
    t.string  "referred_client_code"
    t.string  "entered_by"
    t.string  "entered_bs_date"
    t.string  "nepse_customer_code"
    t.string  "demat_ac_no"
    t.string  "company_code"
    t.string  "mutual_fund"
    t.integer "client_account_id"
  end

  add_index "customer_registration", ["ac_code"], name: "index_customer_registration_on_ac_code", using: :btree
  add_index "customer_registration", ["customer_code"], name: "index_customer_registration_on_customer_code", using: :btree

  create_table "customer_registration_detail", force: :cascade do |t|
    t.string "customer_code"
    t.string "group_code"
    t.string "group_name"
    t.string "director_name"
    t.string "designation"
    t.string "vdc_mp_smp"
    t.string "vdc_mp_smp_name"
    t.string "tole"
    t.string "ward_no"
    t.string "phone_no"
    t.string "email"
    t.string "skype_id"
  end

  create_table "daily_certificate", force: :cascade do |t|
    t.string "transaction_no"
    t.string "certificate_no"
    t.string "kitta_no_from"
    t.string "kitta_no_to"
    t.string "share_holder"
    t.string "total"
    t.string "name_transfer_date"
    t.string "name_transfer_receipt_date"
    t.string "client_certificate_issue_date"
    t.string "fiscal_year"
    t.string "transaction_type"
  end

  create_table "daily_transaction", force: :cascade do |t|
    t.string  "transaction_no"
    t.string  "job_no"
    t.string  "share_code"
    t.string  "quantity"
    t.string  "rate"
    t.string  "customer_code"
    t.string  "broker_no"
    t.string  "broker_job_no"
    t.string  "self_broker_no"
    t.string  "transaction_date"
    t.string  "settlement_date"
    t.string  "transaction_type"
    t.string  "base_price"
    t.string  "transaction_bs_date"
    t.string  "settlement_bs_date"
    t.string  "company_code"
    t.string  "seller_customer_code"
    t.string  "buyer_bill_no"
    t.string  "seller_bill_no"
    t.string  "deposited_date"
    t.string  "receipt_date"
    t.string  "client_account_no"
    t.string  "cash_account_no"
    t.string  "remarks"
    t.string  "cancel_tag"
    t.string  "chalan_no"
    t.string  "buyer_order_no"
    t.string  "seller_order_no"
    t.string  "broker_transaction"
    t.string  "other_broker_transaction"
    t.string  "fiscal_year"
    t.string  "base_price_date"
    t.string  "transaction_status"
    t.string  "nepse_commission"
    t.string  "sebo_commission"
    t.string  "tds"
    t.string  "capital_gain"
    t.string  "capital_gain_tax"
    t.string  "adjusted_purchase_price"
    t.string  "payout_tag"
    t.string  "closeout_quantity"
    t.string  "closeout_amount"
    t.string  "closeout_tag"
    t.string  "receivable_amount"
    t.string  "settlement_id"
    t.string  "voucher_no"
    t.string  "voucher_code"
    t.string  "closeout_voucher_tag"
    t.string  "closeout_voucher_no"
    t.integer "share_transaction_id"
  end

  create_table "daily_transaction_no", force: :cascade do |t|
    t.string "transaction_no"
    t.string "fiscal_year"
  end

  create_table "district_para", force: :cascade do |t|
    t.string "zone_code"
    t.string "district_code"
    t.string "district_name"
  end

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

  create_table "fiscal_year_para", force: :cascade do |t|
    t.string "fiscal_year"
    t.string "fy_start_date"
    t.string "fy_end_date"
    t.string "entered_by"
    t.string "entered_date"
    t.string "year_end"
    t.string "status"
    t.string "fy_start_date_bs"
    t.string "fy_end_date_bs"
  end

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

  create_table "ledger", force: :cascade do |t|
    t.string  "transaction_id"
    t.string  "ac_code"
    t.string  "sub_code"
    t.string  "voucher_code"
    t.string  "voucher_no"
    t.string  "serial_no"
    t.string  "particulars"
    t.string  "amount"
    t.string  "nrs_amount"
    t.string  "transaction_type"
    t.string  "transaction_date"
    t.string  "effective_transaction_date"
    t.string  "bs_date"
    t.string  "book_code"
    t.string  "internal_no"
    t.string  "currency_code"
    t.string  "conversion_rate"
    t.string  "cost_revenue_code"
    t.string  "record_deleted"
    t.string  "cheque_no"
    t.string  "invoice_no"
    t.string  "vou_period"
    t.string  "against_ac_code"
    t.string  "against_sub_code"
    t.string  "fiscal_year"
    t.string  "bill_no"
    t.integer "particular_id"
  end

  create_table "ledger_balances", force: :cascade do |t|
    t.decimal  "opening_balance",      precision: 15, scale: 4, default: 0.0
    t.decimal  "closing_balance",      precision: 15, scale: 4, default: 0.0
    t.decimal  "dr_amount",            precision: 15, scale: 4, default: 0.0
    t.decimal  "cr_amount",            precision: 15, scale: 4, default: 0.0
    t.integer  "fy_code"
    t.integer  "branch_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "ledger_id"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.integer  "opening_balance_type"
  end

  add_index "ledger_balances", ["branch_id"], name: "index_ledger_balances_on_branch_id", using: :btree
  add_index "ledger_balances", ["fy_code", "branch_id", "ledger_id"], name: "index_ledger_balances_on_fy_code_and_branch_id_and_ledger_id", unique: true, using: :btree
  add_index "ledger_balances", ["fy_code"], name: "index_ledger_balances_on_fy_code", using: :btree
  add_index "ledger_balances", ["ledger_id"], name: "index_ledger_balances_on_ledger_id", using: :btree

  create_table "ledger_dailies", force: :cascade do |t|
    t.date     "date"
    t.decimal  "dr_amount",       precision: 15, scale: 4, default: 0.0
    t.decimal  "cr_amount",       precision: 15, scale: 4, default: 0.0
    t.decimal  "opening_balance", precision: 15, scale: 4, default: 0.0
    t.decimal  "closing_balance", precision: 15, scale: 4, default: 0.0
    t.string   "date_bs"
    t.integer  "fy_code"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "ledger_id"
    t.integer  "branch_id"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
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
    t.decimal  "opening_balance_org", precision: 15, scale: 4, default: 0.0
    t.decimal  "closing_balance_org", precision: 15, scale: 4, default: 0.0
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

  create_table "master_setup_commission_details", force: :cascade do |t|
    t.decimal  "start_amount",                    precision: 15, scale: 4
    t.decimal  "limit_amount",                    precision: 15, scale: 4
    t.float    "commission_rate"
    t.float    "commission_amount"
    t.integer  "master_setup_commission_info_id"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  add_index "master_setup_commission_details", ["master_setup_commission_info_id"], name: "master_setup_commission_info_id", using: :btree

  create_table "master_setup_commission_infos", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "start_date_bs"
    t.string   "end_date_bs"
    t.float    "nepse_commission_rate"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

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
    t.integer  "user_access_role_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "menu_permissions", ["creator_id"], name: "index_menu_permissions_on_creator_id", using: :btree
  add_index "menu_permissions", ["menu_item_id"], name: "index_menu_permissions_on_menu_item_id", using: :btree
  add_index "menu_permissions", ["updater_id"], name: "index_menu_permissions_on_updater_id", using: :btree
  add_index "menu_permissions", ["user_access_role_id"], name: "index_menu_permissions_on_user_access_role_id", using: :btree

  create_table "mobile_message", force: :cascade do |t|
    t.string "customer_code"
    t.string "mobile_no"
    t.string "transaction_date"
    t.string "message_date"
    t.string "bill_no"
    t.string "message"
    t.string "message_type"
  end

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

  create_table "nepse_settlements", force: :cascade do |t|
    t.decimal  "settlement_id",   precision: 18
    t.integer  "status",                         default: 0
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.date     "settlement_date"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "type"
  end

  add_index "nepse_settlements", ["creator_id"], name: "index_nepse_settlements_on_creator_id", using: :btree
  add_index "nepse_settlements", ["updater_id"], name: "index_nepse_settlements_on_updater_id", using: :btree

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

  create_table "order_request_details", force: :cascade do |t|
    t.integer  "quantity"
    t.integer  "rate"
    t.integer  "status",           default: 0
    t.integer  "isin_info_id"
    t.integer  "order_request_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "branch_id"
    t.integer  "fy_code"
  end

  add_index "order_request_details", ["isin_info_id"], name: "index_order_request_details_on_isin_info_id", using: :btree
  add_index "order_request_details", ["order_request_id"], name: "index_order_request_details_on_order_request_id", using: :btree

  create_table "order_requests", force: :cascade do |t|
    t.integer  "client_account_id"
    t.string   "date_bs"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "order_requests", ["client_account_id"], name: "index_order_requests_on_client_account_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "order_number"
    t.integer  "client_account_id"
    t.integer  "fy_code"
    t.date     "date"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "orders", ["client_account_id"], name: "index_orders_on_client_account_id", using: :btree

  create_table "organisation_parameter", force: :cascade do |t|
    t.string "org_name"
    t.string "org_address"
    t.string "contact_person"
    t.string "broker_no"
    t.string "off_tel_no"
    t.string "res_tel_no"
    t.string "fax"
    t.string "mobile"
    t.string "max_limit"
    t.string "transaction_no"
    t.string "job_no"
    t.string "cash_deposit"
    t.string "bank_guarantee"
    t.string "pan_no"
    t.string "email"
    t.string "org_name_nepali"
    t.string "org_logo"
  end

  create_table "particular_settlement_associations", id: false, force: :cascade do |t|
    t.integer "association_type", default: 0
    t.integer "particular_id"
    t.integer "settlement_id"
  end

  add_index "particular_settlement_associations", ["particular_id"], name: "index_particular_settlement_associations_on_particular_id", using: :btree
  add_index "particular_settlement_associations", ["settlement_id"], name: "index_particular_settlement_associations_on_settlement_id", using: :btree

  create_table "particulars", force: :cascade do |t|
    t.decimal  "opening_blnc",                     precision: 15, scale: 4, default: 0.0
    t.integer  "transaction_type"
    t.integer  "ledger_type",                                               default: 0
    t.integer  "cheque_number",          limit: 8
    t.string   "name"
    t.string   "description"
    t.decimal  "amount",                           precision: 15, scale: 4, default: 0.0
    t.decimal  "running_blnc",                     precision: 15, scale: 4, default: 0.0
    t.integer  "additional_bank_id"
    t.integer  "particular_status",                                         default: 1
    t.string   "date_bs"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "fy_code"
    t.integer  "branch_id"
    t.date     "transaction_date"
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
    t.integer  "ledger_id"
    t.integer  "voucher_id"
    t.integer  "bank_payment_letter_id"
    t.boolean  "hide_for_client",                                           default: false
  end

  add_index "particulars", ["branch_id"], name: "index_particulars_on_branch_id", using: :btree
  add_index "particulars", ["creator_id"], name: "index_particulars_on_creator_id", using: :btree
  add_index "particulars", ["fy_code"], name: "index_particulars_on_fy_code", using: :btree
  add_index "particulars", ["ledger_id"], name: "index_particulars_on_ledger_id", using: :btree
  add_index "particulars", ["updater_id"], name: "index_particulars_on_updater_id", using: :btree
  add_index "particulars", ["voucher_id"], name: "index_particulars_on_voucher_id", using: :btree

  create_table "particulars_share_transactions", id: false, force: :cascade do |t|
    t.integer "particular_id"
    t.integer "share_transaction_id"
    t.integer "association_type"
  end

  add_index "particulars_share_transactions", ["particular_id"], name: "index_particulars_share_transactions_on_particular_id", using: :btree
  add_index "particulars_share_transactions", ["share_transaction_id"], name: "index_particulars_share_transactions_on_share_transaction_id", using: :btree

  create_table "payout_upload", force: :cascade do |t|
    t.string "transaction_no"
    t.string "transaction_type"
    t.string "transaction_date"
    t.string "company_code"
    t.string "quantity"
    t.string "rate"
    t.string "nepse_commission"
    t.string "sebo_commission"
    t.string "tds"
    t.string "capital_gain"
    t.string "capital_gain_tax"
    t.string "adjusted_purchase_price"
    t.string "closeout_amount"
    t.string "closeout_quantity"
    t.string "settlement_id"
    t.string "receivable_amount"
  end

  create_table "receipt_payment_detail", force: :cascade do |t|
    t.string  "slip_no"
    t.string  "slip_type"
    t.string  "fiscal_year"
    t.string  "cheque_no"
    t.string  "bank_code"
    t.string  "amount"
    t.string  "remarks"
    t.string  "customer_code"
    t.string  "bill_no"
    t.integer "cheque_entry_id"
  end

  add_index "receipt_payment_detail", ["cheque_no"], name: "index_receipt_payment_detail_on_cheque_no", using: :btree
  add_index "receipt_payment_detail", ["fiscal_year"], name: "index_receipt_payment_detail_on_fiscal_year", using: :btree
  add_index "receipt_payment_detail", ["slip_no"], name: "index_receipt_payment_detail_on_slip_no", using: :btree
  add_index "receipt_payment_detail", ["slip_type"], name: "index_receipt_payment_detail_on_slip_type", using: :btree

  create_table "receipt_payment_slip", force: :cascade do |t|
    t.string  "title"
    t.string  "customer_code"
    t.string  "currency_code"
    t.string  "amount"
    t.string  "entered_by"
    t.string  "entered_date"
    t.string  "fiscal_year"
    t.string  "remarks"
    t.string  "payment_type"
    t.string  "ac_code"
    t.string  "slip_no"
    t.string  "slip_date"
    t.string  "slip_type"
    t.string  "manual_slip_no"
    t.string  "settlement_tag"
    t.string  "voucher_no"
    t.string  "voucher_code"
    t.string  "supplier_id"
    t.string  "transaction_no"
    t.string  "void"
    t.string  "bill_no"
    t.string  "pay_to"
    t.string  "cheque_printed"
    t.string  "issue_date"
    t.integer "settlement_id"
  end

  add_index "receipt_payment_slip", ["voucher_code"], name: "index_receipt_payment_slip_on_voucher_code", using: :btree
  add_index "receipt_payment_slip", ["voucher_no"], name: "index_receipt_payment_slip_on_voucher_no", using: :btree

  create_table "sector_parameter", force: :cascade do |t|
    t.string "sector_code"
    t.string "sector_name"
  end

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
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.integer  "branch_id"
    t.integer  "settlement_by_cheque_type",                          default: 0
    t.date     "date"
    t.boolean  "belongs_to_batch_payment"
    t.decimal  "cash_amount",               precision: 15, scale: 2
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

  create_table "share_parameter", force: :cascade do |t|
    t.string "share_code"
    t.string "share_description"
  end

  create_table "share_receipt", force: :cascade do |t|
    t.string "receipt_no"
    t.string "received_date"
    t.string "customer_code"
    t.string "received_by"
    t.string "fiscal_year"
    t.string "remarks"
  end

  create_table "share_receipt_detail", force: :cascade do |t|
    t.string "receipt_no"
    t.string "company_code"
    t.string "received_quantity"
    t.string "rec_certificate_no"
    t.string "rec_kitta_no_from"
    t.string "rec_kitta_no_to"
    t.string "returned_quantity"
    t.string "ret_certificate_no"
    t.string "ret_kitta_no_from"
    t.string "ret_kitta_no_to"
    t.string "returned_date"
    t.string "returned_by"
    t.string "fiscal_year"
  end

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
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
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
    t.date     "settlement_date"
    t.boolean  "closeout_settled",                                   default: false
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
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "phone"
    t.integer  "phone_type",             default: 0
    t.integer  "sms_type",               default: 0
    t.integer  "credit_used"
    t.integer  "remarks"
    t.integer  "transaction_message_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "fy_code"
    t.integer  "branch_id"
  end

  add_index "sms_messages", ["branch_id"], name: "index_sms_messages_on_branch_id", using: :btree
  add_index "sms_messages", ["creator_id"], name: "index_sms_messages_on_creator_id", using: :btree
  add_index "sms_messages", ["fy_code"], name: "index_sms_messages_on_fy_code", using: :btree
  add_index "sms_messages", ["transaction_message_id"], name: "index_sms_messages_on_transaction_message_id", using: :btree
  add_index "sms_messages", ["updater_id"], name: "index_sms_messages_on_updater_id", using: :btree

  create_table "supplier", force: :cascade do |t|
    t.string "supplier_name"
    t.string "supplier_address"
    t.string "supplier_no"
    t.string "supplier_email"
    t.string "contact_person"
    t.string "supplier_fax"
    t.string "supplier_id"
    t.string "pan_no"
    t.string "vat_no"
    t.string "supplier_type"
    t.string "due_days"
    t.string "ac_code"
  end

  create_table "supplier_bill", force: :cascade do |t|
    t.string "bill_no"
    t.string "bill_date"
    t.string "manual_no"
    t.string "supplier_id"
    t.string "prepare_by"
    t.string "fiscal_year"
    t.string "voucher_no"
    t.string "prepared_on"
    t.string "voucher_code"
    t.string "ac_code"
  end

  create_table "supplier_bill_detail", force: :cascade do |t|
    t.string "bill_no"
    t.string "particular"
    t.string "quantity"
    t.string "unit_price"
    t.string "total_price"
    t.string "remarks"
  end

  create_table "supplier_ledger", force: :cascade do |t|
    t.string "supplier_id"
    t.string "bill_no"
    t.string "settlement_date"
    t.string "particulars"
    t.string "entered_by"
    t.string "entered_date"
    t.string "fiscal_year"
    t.string "transaction_date"
    t.string "dr_amount"
    t.string "cr_amount"
    t.string "transaction_id"
    t.string "slip_no"
    t.string "slip_type"
    t.string "settlement_tag"
    t.string "remarks"
    t.string "quantity"
  end

  create_table "system_para", force: :cascade do |t|
    t.string "nepse_purchase_ac"
    t.string "nepse_sales_ac"
    t.string "commission_purchase_ac"
    t.string "commission_sales_ac"
    t.string "name_transfer_rate"
    t.string "nepse_capital_ac"
    t.string "extra_commission_charge"
    t.string "voucher_tag"
    t.string "voucher_code"
    t.string "name_transfer_ac"
    t.string "cash_ac"
    t.string "tds_ac"
    t.string "sebo_ac"
    t.string "demat_fee"
    t.string "demat_fee_ac"
    t.string "cds_fee_ac"
    t.string "sebon_fee_ac"
    t.string "sebon_regularity_fee_ac"
  end

  create_table "tax_para", force: :cascade do |t|
    t.string "unit_id"
    t.string "effective_date_from"
    t.string "effective_date_to"
    t.string "rate"
    t.string "tax_name"
  end

  create_table "temp_daily_transaction", force: :cascade do |t|
    t.string "transaction_no"
    t.string "company_code"
    t.string "buyer_broker_no"
    t.string "seller_broker_no"
    t.string "customer_name"
    t.string "quantity"
    t.string "rate"
    t.string "amount"
    t.string "stock_commission"
    t.string "bank_deposit"
    t.string "transaction_date"
    t.string "transaction_bs_date"
    t.string "fiscal_year"
    t.string "nepse_code"
  end

  create_table "temp_name_transfer", force: :cascade do |t|
    t.string "transaction_no"
    t.string "quantity"
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
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "closeout_settlement_automatic", default: false
  end

  create_table "transaction_messages", force: :cascade do |t|
    t.string   "sms_message"
    t.date     "transaction_date"
    t.integer  "sms_status",        default: 0
    t.integer  "email_status",      default: 0
    t.integer  "bill_id"
    t.integer  "client_account_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.date     "deleted_at"
    t.integer  "sent_sms_count",    default: 0
    t.integer  "sent_email_count",  default: 0
    t.string   "remarks_email"
    t.string   "remarks_sms"
  end

  add_index "transaction_messages", ["bill_id"], name: "index_transaction_messages_on_bill_id", using: :btree
  add_index "transaction_messages", ["client_account_id"], name: "index_transaction_messages_on_client_account_id", using: :btree

  create_table "user_access_roles", force: :cascade do |t|
    t.integer  "role_type",   default: 0
    t.string   "role_name"
    t.text     "description"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: ""
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
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
    t.integer  "user_access_role_id"
    t.string   "username"
    t.boolean  "pass_changed",           default: false
    t.string   "temp_password"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

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

  create_table "voucher", force: :cascade do |t|
    t.string  "voucher_no"
    t.string  "voucher_code"
    t.string  "serial_no"
    t.string  "voucher_date"
    t.string  "bs_date"
    t.string  "dr_ac_code"
    t.string  "dr_sub_code"
    t.string  "cr_ac_code"
    t.string  "cr_sub_code"
    t.string  "narration"
    t.string  "paid_to_received_from"
    t.string  "cheque_no"
    t.string  "prepared_by"
    t.string  "checked_by"
    t.string  "approved_by"
    t.string  "authorized_by"
    t.string  "transaction_no"
    t.string  "fiscal_year"
    t.string  "bill_no"
    t.string  "posted_by"
    t.integer "voucher_id"
    t.boolean "migration_completed",   default: false
    t.date    "voucher_date_parsed"
  end

  add_index "voucher", ["voucher_code"], name: "index_voucher_on_voucher_code", using: :btree
  add_index "voucher", ["voucher_no"], name: "index_voucher_on_voucher_no", using: :btree

  create_table "voucher_detail", force: :cascade do |t|
    t.string "voucher_no"
    t.string "voucher_code"
    t.string "ac_code"
    t.string "sub_code"
    t.string "particulars"
    t.string "currency_code"
    t.string "amount"
    t.string "conversion_rate"
    t.string "nrs_amount"
    t.string "transaction_type"
    t.string "cost_revenue_code"
    t.string "invoice_no"
    t.string "vou_period"
    t.string "against_ac_code"
    t.string "against_sub_code"
    t.string "cheque_no"
    t.string "fiscal_year"
    t.string "serial_no"
  end

  add_index "voucher_detail", ["voucher_code"], name: "index_voucher_detail_on_voucher_code", using: :btree
  add_index "voucher_detail", ["voucher_no"], name: "index_voucher_detail_on_voucher_no", using: :btree

  create_table "voucher_number_configuration", force: :cascade do |t|
    t.string "no_code"
    t.string "voucher_no_format"
  end

  create_table "voucher_number_detail", force: :cascade do |t|
    t.string "no_code"
    t.string "part_no"
    t.string "character_length"
    t.string "choice_of_part"
    t.string "other_constant"
    t.string "number_format"
  end

  create_table "voucher_parameter", force: :cascade do |t|
    t.string "voucher_code"
    t.string "voucher_name"
    t.string "voucher_type"
    t.string "dr_ac_code"
    t.string "dr_sub_code"
    t.string "cr_ac_code"
    t.string "cr_sub_code"
    t.string "check_dr_code"
    t.string "check_cr_code"
    t.string "checked_by"
    t.string "approved_by"
    t.string "authorized_by"
    t.string "voucher_no_code"
  end

  create_table "voucher_particulars", force: :cascade do |t|
    t.string "bill_no"
    t.string "count_shares"
    t.string "no_of_shares"
    t.string "rate_per_share"
    t.string "company_code"
    t.string "commission_rate"
    t.string "fiscal_year"
    t.string "transaction_fee"
  end

  create_table "voucher_transaction", force: :cascade do |t|
    t.string "voucher_no"
    t.string "voucher_code"
    t.string "fiscal_year"
  end

  create_table "voucher_user", force: :cascade do |t|
    t.string "voucher_code"
    t.string "voucher_name"
    t.string "voucher_type"
    t.string "user_code"
    t.string "status"
  end

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

  create_table "zone_para", force: :cascade do |t|
    t.string "regional_code"
    t.string "zone_code"
    t.string "zone_name"
  end

  add_foreign_key "bank_payment_letters", "branches"
  add_foreign_key "bank_payment_letters", "nepse_settlements"
  add_foreign_key "bank_payment_letters", "vouchers"
  add_foreign_key "bill_voucher_associations", "bills"
  add_foreign_key "bill_voucher_associations", "vouchers"
  add_foreign_key "cheque_entry_particular_associations", "cheque_entries"
  add_foreign_key "cheque_entry_particular_associations", "particulars"
  add_foreign_key "ledger_balances", "ledgers"
  add_foreign_key "master_setup_commission_details", "master_setup_commission_infos"
  add_foreign_key "menu_permissions", "menu_items"
  add_foreign_key "nepse_chalans", "vouchers"
  add_foreign_key "order_request_details", "order_requests"
  add_foreign_key "order_requests", "client_accounts"
  add_foreign_key "particular_settlement_associations", "particulars"
  add_foreign_key "particular_settlement_associations", "settlements"
  add_foreign_key "particulars_share_transactions", "particulars"
  add_foreign_key "particulars_share_transactions", "share_transactions"
  add_foreign_key "settlements", "vouchers"
  add_foreign_key "sms_messages", "transaction_messages"
  add_foreign_key "transaction_messages", "client_accounts"
end
