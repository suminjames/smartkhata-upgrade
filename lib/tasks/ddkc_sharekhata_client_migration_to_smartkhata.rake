
# Populate date column with date_ad that is equivalent to date_bs, which is already a column in the table.
task :migrate_ddkc_sharekhata_clients_to_smartkhata, [:tenant] => :environment do |task, args|
  include CustomDateModule
  if args.tenant.blank? || args.tenant != 'dipshikha'
    fail "Invalid tenant! This migration can apparently only be run in dipskhika tenant as of now."
  end

  Apartment::Tenant.switch!(args.tenant)
  UserSession.set_console('dipshikha')

  dir = "#{Rails.root}/test_files/ddkc_sharekhata_client_migration_to_smartkhata/"
  file_with_client_accounts_from_sharekhata = dir + 'dipshikha_accounts_20161209152140.csv'
  file_with_nepse_code_and_boid = dir + 'c_map.csv'

  # Load client accounts from file
  client_accounts_arr = []
  csv_text = File.read(file_with_client_accounts_from_sharekhata)
  csv = CSV.parse(csv_text, :headers => true)
  csv.each do |row|
    client_accounts_arr << row.to_hash
  end

  # load all client accounts' boid and nepse_code mapping in a hash
  client_account_boid_nepse_code_mappings = {}
  csv_text = File.read(file_with_nepse_code_and_boid)
  csv = CSV.parse(csv_text, :headers => false)
  nepse_code_col = 0
  boid_col = 4
  csv.each do |row|
    nepse_code = row[nepse_code_col]
    boid = row[boid_col]
    if nepse_code.empty? || nepse_code.include?(' ')
      puts "Warning! Invalid nepse code `#{nepse_code}`. Dropped for migration."
    else
      client_account_boid_nepse_code_mappings[boid] = nepse_code
    end
  end

  # Account model signature in ShareKhata
  #  id
  #  boid
  #  date
  #  name
  #  address1
  #  address1_perm
  #  address2
  #  address2_perm
  #  address3
  #  address3_perm
  #  city
  #  city_perm
  #  state
  #  state_perm
  #  country
  #  country_perm
  #  phone
  #  phone_perm
  #  customer_product_no
  #  dp_id
  #  dob
  #  sex
  #  nationality
  #  stmt_cycle_code
  #  ac_suspension_fl
  #  profession_code
  #  income_code
  #  electronic_dividend
  #  dividend_curr
  #  email
  #  father_husband
  #  citizen_passport
  #  granfather_spouse
  #  purpose_code_add
  #  add_holder
  #  invited
  #  user_id
  #  created_at
  #  updated_at
  #  expiration_date
  #  account_balance

  # Insert client accounts from file into db
  ActiveRecord::Base.transaction do
    client_accounts_arr.each_with_index do |client_account, index|
      if client_account_boid_nepse_code_mappings[client_account["boid"]].present?
        puts client_account
        ClientAccount.find_or_create_by!(boid: client_account["boid"]) do |new_client_account|
          new_client_account.skip_validation_for_system = true
          new_client_account.nepse_code = client_account_boid_nepse_code_mappings[client_account["boid"]]
          new_client_account.name = client_account["name"]
          new_client_account.address1 = client_account["address1"]
          new_client_account.address1_perm = client_account["address1_perm"]
          new_client_account.address2 = client_account["address2"]
          new_client_account.address2_perm = client_account["address2_perm"]
          new_client_account.address3 = client_account["address3"]
          new_client_account.address3_perm = client_account["address3_perm"]
          new_client_account.city = client_account["city"]
          new_client_account.city_perm = client_account["city_perm"]
          new_client_account.state = client_account["state"]
          new_client_account.state_perm = client_account["state_perm"]
          new_client_account.country = client_account["country"]
          new_client_account.country_perm = client_account["country_perm"]
          new_client_account.phone = client_account["phone"]
          new_client_account.phone_perm = client_account["phone_perm"]
          new_client_account.customer_product_no = client_account["customer_product_no"]
          new_client_account.dp_id = client_account["dp_id"]
          new_client_account.sex = client_account["sex"]
          new_client_account.nationality = client_account["nationality"]
          new_client_account.stmt_cycle_code = client_account["stmt_cycle_code"]
          new_client_account.ac_suspension_fl = client_account["ac_suspension_fl"]
          new_client_account.profession_code = client_account["profession_code"]
          new_client_account.income_code = client_account["income_code"]
          new_client_account.electronic_dividend = client_account["electronic_dividend"]
          new_client_account.dividend_curr = client_account["dividend_curr"]
          new_client_account.email = client_account["email"]
          new_client_account.father_mother= client_account["father_husband"]
          new_client_account.citizen_passport = client_account["citizen_passport"]
          new_client_account.purpose_code_add = client_account["purpose_code_add"]
          new_client_account.add_holder = client_account["add_holder"]
          dob_str = client_account["dob"]
          if dob_str.present? && is_convertible_ad_date?(Date.parse(dob_str))
            new_client_account.dob = ad_to_bs_string(Date.parse(dob_str))
          end
        end
      end
    end
  end

  Apartment::Tenant.switch!('public')

end
