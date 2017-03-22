# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# only when verbose is true show error message
# not needed for test setup
verbose = Rails.env == 'test' ? false : true

tenant = Tenant.find_or_create_by!(name: "demo", dp_id: '1010')
tenant.update(full_name: 'Danphe InfoTech Private Ltd.', address: 'Kupondole, Lalitpur', phone_number: '977-1-4232132', fax_number: '977-1-4232133', pan_number: '302830905', broker_code: '99')

tenant = Tenant.find_or_create_by!(name: "smartkhata", dp_id: '1010')
tenant.update(full_name: 'Danphe InfoTech Private Ltd.', address: 'Kupondole, Lalitpur', phone_number: '977-1-4232132', fax_number: '977-1-4232133', pan_number: '302830905', broker_code: '88')

@tenants = Tenant.all

@admin_users = [
    {:email => 'demo@danfeinfotech.com', :password => '12demo09'},
    {:email => 'demo@danfeinfotech.com', :password => '12demo09'}, #for the public
]



count = 0
@tenants.each do |t|
  begin
    puts "Creating Tenant..." if verbose
    count += 1

    # since seed runs for each tenant
    # need to make sure it will run only once
    unless t == "public"
      Apartment::Tenant.create(t.name)
      Apartment::Tenant.switch!(t.name)
    else
      Apartment::Tenant.switch!("public")
      next if User.count > 0
    end

    branch = Branch.create(code: "KTM", address: "Kathmandu")
    admin_user_data = @admin_users[count - 1]
    new_user = User.find_or_create_by!(email: admin_user_data[:email]) do |user|
      user.password = admin_user_data[:password]
      user.password_confirmation = admin_user_data[:password]
      user.branch_id = branch.id
      user.confirm
      user.admin!
    end
    puts 'CREATED ADMIN USER: ' << new_user.email  if verbose
    UserSession.user = new_user

    Group.create!([
                     { name: "Capital", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities'], for_trial_balance: true},
                     {name: "Fixed Assets", report: Group.reports['Balance'], sub_report: Group.sub_reports['Assets'], for_trial_balance: true}])

    group = Group.create({name: "Reserve & Surplus", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities']})
    groups = Group.create([
                              { name: "Profit & Loss Account", for_trial_balance: true},
                              {name: "General Reserve"},
                              {name: "Capital Reserve"},
                              # {name: "Purchase", report: Group.reports['PNL'], sub_report: Group.sub_reports['Expense']},
                              # {name: "Sales", report: Group.reports['PNL'], sub_report: Group.sub_reports['Income']},
                              {name: "Direct Income", report: Group.reports['PNL'], sub_report: Group.sub_reports['Income'], for_trial_balance: true},
                              {name: "Indirect Income", report: Group.reports['PNL'], sub_report: Group.sub_reports['Income'], for_trial_balance: true},
                              { name: "Direct Expense", report: Group.reports['PNL'], sub_report: Group.sub_reports['Expense'], for_trial_balance: true},
                              {name: "Indirect Expense", report: Group.reports['PNL'], sub_report: Group.sub_reports['Expense'], for_trial_balance: true}
                          ])

    group.children << groups
    group.save!

    group = Group.find_by(name: "Direct Income")
    ledgers = Ledger.create([{name: "Purchase Commission"},{name: "Sales Commission"}])
    group.ledgers << ledgers
    group.save!

    group = Group.create({name: "Loan", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities'], for_trial_balance: true})
    groups = Group.create([{ name: "Secured Loan"},{name: "Unsecured Loan"}])
    group.children << groups
    group.save!

    group = Group.create({name: "Current Liabilities", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities'], for_trial_balance: true})
    groups = Group.create([{ name: "Duties & Taxes"},{name: "Sundry Creditors"},{name: "Account Payables"}])
    ledgers = Ledger.create([{name: "DP Fee/ Transfer"}, {name: "Nepse Purchase"}, {name: "Nepse Sales"}, {name: "Clearing Account"}, {name: 'Compliance Fee'}])
    group.children << groups
    group.ledgers << ledgers
    group.save!

    group = Group.create({name: "Current Assets",report: Group.reports['Balance'], sub_report: Group.sub_reports['Assets'], for_trial_balance: true})
    groups = Group.create([{ name: "Advances and Receivables"},{name: "Sundry Debtors"},{name: "Account Receivables"}, {name: "Clients"}, {name: "Clearing Account"}])
    group.children << groups
    ledgers = Ledger.create([{name: "TDS"},{name: "Cash"},{name: 'Close Out'}])
    group.ledgers << ledgers
    group.save!

    Bank.create([{name: "Nepal Investment Pvt. Ltd", bank_code: "NIBL"},{name: "Global IME ", bank_code: "GIME"}, {name: "Nabil Bank Ltd", bank_code:'NBL'}])

    puts "populating commission details"  if verbose
    commission_rate = MasterSetup::CommissionInfo.new(start_date: Date.parse('2011-01-01'), end_date: '2016-07-23', nepse_commission_rate: 25)
    commission_details = MasterSetup::CommissionDetail
                             .create([
                                         {start_amount: 0, limit_amount: 2500, commission_amount: 25},
                                         {start_amount: 2500, limit_amount: 50000.0, commission_rate: 1.0},
                                         {start_amount: 50000, limit_amount: 500000.0, commission_rate: 0.9},
                                         {start_amount: 500000.0, limit_amount: 1000000.0, commission_rate: 0.8},
                                         {start_amount: 	1000000.0, limit_amount: 99999999999.0, commission_rate: 0.7},
                                     ])

    commission_rate.commission_details << commission_details
    commission_rate.save!

    commission_rate = MasterSetup::CommissionInfo.new(start_date: Date.parse('2016-07-24'), end_date: '2021-12-31', nepse_commission_rate: 20)

    commission_details = MasterSetup::CommissionDetail
                             .create([
                                         {start_amount: 0, limit_amount: 4166.67, commission_amount: 25},
                                         {start_amount: 4166.67, limit_amount: 50000.0, commission_rate: 0.6},
                                         {start_amount: 50000, limit_amount: 500000.0, commission_rate: 0.55},
                                         {start_amount: 500000.0, limit_amount: 2000000.0, commission_rate: 0.5},
                                         {start_amount: 2000000.0, limit_amount: 	10000000.0, commission_rate: 0.45},
                                         {start_amount: 	10000000.0, limit_amount: 99999999999.0, commission_rate: 0.4},
                                     ])

    commission_rate.commission_details << commission_details
    commission_rate.save!



    puts " Populating calendar..." if verbose
    Calendar.populate_calendar

    puts "putting the menus"  if verbose
    MenuItemService.new.call

  rescue => error
    puts error.message  if verbose
    puts "Tenant #{t.name} exists"  if verbose
  end

  Apartment::Tenant.switch!('public')
end

