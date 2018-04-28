# In a prior migration of client accounts from ShareKhata to SmartKhata, client type was not properly assigned.
# This resulted in each new client account creation to have client_type (default value ) of 0 (ie. Individual).
# However, there were clients with client_type of Corporate. This will result in accounting mishap due to different CGT
# rates. Check which client's client_type are mismatched.
task :test_for_client_account_mismatch_during_ddkc_sharekhata_clients_migration_to_smartkhata, [:tenant] => :environment do |task, args|
  if args.tenant.blank? || args.tenant != 'dipshikha'
    fail "Invalid tenant! This migration can apparently only be run in dipskhika tenant as of now."
  end
  UserSession.set_console('dipshikha')

  dir = "#{Rails.root}/test_files/ddkc_sharekhata_client_migration_to_smartkhata/"
  file_with_nepse_code_and_boid = dir + 'c_map.csv'
  file_with_client_accounts_from_sharekhata = dir + 'dipshikha_accounts_20161209152140.csv'

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
  client_type_col = 1
  boid_col = 4
  csv.each do |row|
    nepse_code = row[nepse_code_col].upcase.strip
    boid = row[boid_col]
    client_type = row[client_type_col].downcase
    client_type = "individual" if client_type == "minor"
    if nepse_code.empty? || nepse_code.include?(' ')
      puts "Warning! Invalid nepse code `#{nepse_code}`. Dropped for migration."
    else
      client_account_boid_nepse_code_mappings[boid] = {client_type: client_type, nepse_code: nepse_code}
    end
  end

  ap client_account_boid_nepse_code_mappings

  client_accounts_arr.each_with_index do |client_account, index|
    if client_account_boid_nepse_code_mappings[client_account["boid"]].present?
      nepse_code = client_account_boid_nepse_code_mappings[client_account["boid"]][:nepse_code]
      client_type = client_account_boid_nepse_code_mappings[client_account["boid"]][:client_type]
      puts
      puts "Inspecting #{nepse_code} of type #{client_type}..."
      client_accounts = ClientAccount.where("UPPER(nepse_code) = ?", nepse_code.upcase)
      if client_accounts.size == 0
        puts "CAUTION! No client account found."
      elsif client_accounts.size > 1
        puts "CAUTION! Duplicate nepse code."
      else
        client_account =  ClientAccount.unscoped.find_by_nepse_code(nepse_code)
        client_type_in_db = client_account.client_type
        if  client_type_in_db == client_type
          puts "Ok.."
        else
          puts "Client type Mismatch for client(id: #{client_account.id})! In csv #{client_type}. In db #{client_type_in_db}"
          puts "Client account deletable: #{client_account.deletable?}"
        end
      end
    end
  end

  Apartment::Tenant.switch!('public')
end

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
  counter = 0
  ActiveRecord::Base.transaction do
    client_accounts_arr.each_with_index do |client_account, index|
      if client_account_boid_nepse_code_mappings[client_account["boid"]].present?
        counter += 1
        p counter
        puts client_account
        client_account_in_db = ClientAccount.find_by_nepse_code(client_account_boid_nepse_code_mappings[client_account["boid"]])
        if client_account_in_db.blank?
          client_account_in_db = ClientAccount.new
        end
        client_account_in_db.skip_validation_for_system = true
        client_account_in_db.nepse_code = client_account_boid_nepse_code_mappings[client_account["boid"]]
        client_account_in_db.name = client_account["name"]
        client_account_in_db.address1 = client_account["address1"]
        client_account_in_db.address1_perm = client_account["address1_perm"]
        client_account_in_db.address2 = client_account["address2"]
        client_account_in_db.address2_perm = client_account["address2_perm"]
        client_account_in_db.address3 = client_account["address3"]
        client_account_in_db.address3_perm = client_account["address3_perm"]
        client_account_in_db.city = client_account["city"]
        client_account_in_db.city_perm = client_account["city_perm"]
        client_account_in_db.state = client_account["state"]
        client_account_in_db.state_perm = client_account["state_perm"]
        client_account_in_db.country = client_account["country"]
        client_account_in_db.country_perm = client_account["country_perm"]
        client_account_in_db.phone = client_account["phone"]
        client_account_in_db.phone_perm = client_account["phone_perm"]
        client_account_in_db.customer_product_no = client_account["customer_product_no"]
        client_account_in_db.dp_id = client_account["dp_id"]
        client_account_in_db.sex = client_account["sex"]
        client_account_in_db.nationality = client_account["nationality"]
        client_account_in_db.stmt_cycle_code = client_account["stmt_cycle_code"]
        client_account_in_db.ac_suspension_fl = client_account["ac_suspension_fl"]
        client_account_in_db.profession_code = client_account["profession_code"]
        client_account_in_db.income_code = client_account["income_code"]
        client_account_in_db.electronic_dividend = client_account["electronic_dividend"]
        client_account_in_db.dividend_curr = client_account["dividend_curr"]
        client_account_in_db.email = client_account["email"]
        client_account_in_db.father_mother= client_account["father_husband"]
        client_account_in_db.citizen_passport = client_account["citizen_passport"]
        client_account_in_db.purpose_code_add = client_account["purpose_code_add"]
        client_account_in_db.add_holder = client_account["add_holder"]
        dob_str = client_account["dob"]
        if dob_str.present? && is_convertible_ad_date?(Date.parse(dob_str))
          client_account_in_db.dob = ad_to_bs_string(Date.parse(dob_str))
        end
        client_account_in_db.save!
      end
    end
  end

  Apartment::Tenant.switch!('public')

end
