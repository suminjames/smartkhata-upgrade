# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



# tenant = Tenant.find_or_create_by!(name: "dipshikha", dp_id: '11000')
# tenant.update(full_name: 'Dipshikha Dhitopatra Karobar Company Pvt. Ltd.', address: 'Anamnagar, Kathmandu', phone_number: '977-1-4444444', fax_number: '977-1-4444444', pan_number: '55555555', broker_code: '38')
# tenant = Tenant.find_or_create_by!(name: "trishakti", dp_id: '11400')
# tenant.update(full_name: 'Trishakti Securities Public Ltd.', address: 'Putalisadak, Kathmandu', phone_number: '977-1-4232132', fax_number: '977-1-4232133', pan_number: '302830905', broker_code: '48')
# tenant = Tenant.find_or_create_by!(name: "public", dp_id: '11400')
# tenant.update(full_name: 'Trishakti Securities Public Ltd.', address: 'Putalisadak, Kathmandu', phone_number: '977-1-4232132', fax_number: '977-1-4232133', pan_number: '302830905', broker_code: '48')
# @tenants = Tenant.all


@tenants = []
# tenant = Tenant.find_or_create_by!(name: "smartkhata", dp_id: '1010')
# tenant.update(full_name: 'Danphe InfoTech Private Ltd.', address: 'Kupondole, Lalitpur', phone_number: '977-1-4232132', fax_number: '977-1-4232133', pan_number: '302830905', broker_code: '00')
# @tenants << tenant
tenant = Tenant.find_or_create_by!(name: "danphe", dp_id: '1010')
tenant.update(full_name: 'Danphe InfoTech Private Ltd.', address: 'Kupondole, Lalitpur', phone_number: '977-1-4232132', fax_number: '977-1-4232133', pan_number: '302830905', broker_code: '00')
@tenants << tenant


# @admin_users = [
#     {:email => 'dipshikha@danfeinfotech.com', :password => 'dipshikha5645'},
#     {:email => 'trishakti@danfeinfotech.com', :password => 'trispa8934'},
#     {:email => 'trishakti@danfeinfotech.com', :password => 'trispa8934'}
# ]

@admin_users = [
    # {:email => 'demo@danfeinfotech.com', :password => '12demo09'},
    {:email => 'danphe@danfeinfotech.com', :password => '32Dan089'},
]

count = 0
@tenants.each do |t|
  begin
    puts "Creating Tenant..."
    count += 1
    Apartment::Tenant.create(t.name)
    Apartment::Tenant.switch!(t.name)

    branch = Branch.create(code: "KTM", address: "Kathmandu")
    admin_user_data = @admin_users[count - 1]
    new_user = User.find_or_create_by!(email: admin_user_data[:email]) do |user|
      user.password = admin_user_data[:password]
      user.password_confirmation = admin_user_data[:password]
      user.branch_id = branch.id
      user.confirm!
      user.admin!
    end
    puts 'CREATED ADMIN USER: ' << new_user.email
    UserSession.user = new_user

    Group.create([
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
    ledgers = Ledger.create([{name: "DP Fee/ Transfer"}, {name: "Nepse Purchase"}, {name: "Nepse Sales"}, {name: "Clearing Account"}])
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

    puts " Populating calendar..."
    Calendar.populate_calendar

  rescue => error
    puts error.message
    puts "Tenant #{t.name} exists"
  end

  Apartment::Tenant.switch!('public')
end

