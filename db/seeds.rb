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

# tenant = Tenant.find_or_create_by!(name: "smartkhata", dp_id: '1010')
# tenant.update(full_name: 'Danphe InfoTech Private Ltd.', address: 'Kupondole, Lalitpur', phone_number: '977-1-4232132', fax_number: '977-1-4232133', pan_number: '302830905', broker_code: '88')

@tenants = Tenant.all

@admin_users = [
    {:email => 'demo@danfeinfotech.com', :password => '12demo09'},
    {:email => 'demo@danfeinfotech.com', :password => '12demo09'}, #for the public
]


def general_klass_setup(attrs, klass, user_id, relation_params = {})
  if attrs.is_a? Array
    attrs.map{|attr| attr.merge!(relation_params).merge!(current_user_id: user_id) }
  else
    attrs.merge!(relation_params).merge!(current_user_id: user_id)
  end
  klass.create(attrs)
end

def commission_klass_setup(attrs, klass, relation_params = {})
  if attrs.is_a? Array
    attrs.map{|attr| attr.merge!(relation_params)}
  else
    attrs.merge!(relation_params)
  end
  klass == MasterSetup::CommissionInfo ? klass.new(attrs) : klass.create(attrs)
end

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
    current_user_id = new_user.id

    general_klass_setup([
                     { name: "Capital", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities'], for_trial_balance: true},
                     {name: "Fixed Assets", report: Group.reports['Balance'], sub_report: Group.sub_reports['Assets'], for_trial_balance: true}
                 ], Group, current_user_id)

    group = general_klass_setup({name: "Reserve & Surplus", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities']}, Group, current_user_id)
    general_klass_setup([
                    { name: "Profit & Loss Account", for_trial_balance: true},
                    {name: "General Reserve"},
                    {name: "Capital Reserve"},
                    # {name: "Purchase", report: Group.reports['PNL'], sub_report: Group.sub_reports['Expense']},
                    # {name: "Sales", report: Group.reports['PNL'], sub_report: Group.sub_reports['Income']},
                    {name: "Direct Income", report: Group.reports['PNL'], sub_report: Group.sub_reports['Income'], for_trial_balance: true},
                    {name: "Indirect Income", report: Group.reports['PNL'], sub_report: Group.sub_reports['Income'], for_trial_balance: true},
                    { name: "Direct Expense", report: Group.reports['PNL'], sub_report: Group.sub_reports['Expense'], for_trial_balance: true},
                    {name: "Indirect Expense", report: Group.reports['PNL'], sub_report: Group.sub_reports['Expense'], for_trial_balance: true}
                  ], Group, current_user_id, { parent_id: group.id })

    group = Group.find_by(name: "Direct Income")
    general_klass_setup([
                   {name: "Purchase Commission" },
                   {name: "Sales Commission" }
                 ], Ledger, current_user_id, { group_id: group.id })

    group = general_klass_setup({name: "Loan", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities'], for_trial_balance: true}, Group, current_user_id)
    general_klass_setup([
                   { name: "Secured Loan"},
                   {name: "Unsecured Loan"}
                 ], Group, current_user_id, { parent_id: group.id })

    group = general_klass_setup({name: "Current Liabilities", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities'], for_trial_balance: true}, Group, current_user_id)
    general_klass_setup([
                   { name: "Duties & Taxes"},
                   {name: "Sundry Creditors"},
                   {name: "Account Payables"}
                 ], Group, current_user_id, { parent_id: group.id })
    general_klass_setup([
                   {name: "DP Fee/ Transfer"},
                   {name: "Nepse Purchase"},
                   {name: "Nepse Sales"},
                   {name: "Clearing Account"},
                   {name: 'Compliance Fee'}
                 ], Ledger, current_user_id, { group_id: group.id})
    
    group = general_klass_setup({name: "Current Assets",report: Group.reports['Balance'], sub_report: Group.sub_reports['Assets'], for_trial_balance: true}, Group, current_user_id)
    general_klass_setup([
                   { name: "Advances and Receivables"},
                   {name: "Sundry Debtors"},
                   {name: "Account Receivables"},
                   {name: "Clients"},
                   {name: "Clearing Account"}
                 ], Group, current_user_id, parent_id: group.id)
    general_klass_setup([
                   {name: "TDS"},
                   {name: "Cash"},
                   {name: 'Close Out'}
                 ], Ledger, current_user_id, group_id: group.id)

    general_klass_setup([{name: "Nepal Investment Pvt. Ltd", bank_code: "NIBL"},{name: "Global IME ", bank_code: "GIME"}, {name: "Nabil Bank Ltd", bank_code:'NBL'}], Bank, current_user_id)

    puts "populating commission details"  if verbose
    
    commission_rate = commission_klass_setup({start_date: Date.parse('2011-01-01'), end_date: '2016-07-23', nepse_commission_rate: 25}, MasterSetup::CommissionInfo)
    commission_klass_setup([
                                 {start_amount: 0, limit_amount: 2500, commission_amount: 25},
                                 {start_amount: 2500, limit_amount: 50000.0, commission_rate: 1.0},
                                 {start_amount: 50000, limit_amount: 500000.0, commission_rate: 0.9},
                                 {start_amount: 500000.0, limit_amount: 1000000.0, commission_rate: 0.8},
                                 {start_amount: 	1000000.0, limit_amount: 99999999999.0, commission_rate: 0.7},
                           ], MasterSetup::CommissionDetail, master_setup_commission_info_id: commission_rate.id)
    
    commission_rate = commission_klass_setup({start_date: Date.parse('2016-07-24'), end_date: '2021-12-31', nepse_commission_rate: 20}, MasterSetup::CommissionInfo)
    commission_klass_setup([
                                 {start_amount: 0, limit_amount: 4166.67, commission_amount: 25},
                                 {start_amount: 4166.67, limit_amount: 50000.0, commission_rate: 0.6},
                                 {start_amount: 50000, limit_amount: 500000.0, commission_rate: 0.55},
                                 {start_amount: 500000.0, limit_amount: 2000000.0, commission_rate: 0.5},
                                 {start_amount: 2000000.0, limit_amount: 	10000000.0, commission_rate: 0.45},
                                 {start_amount: 	10000000.0, limit_amount: 99999999999.0, commission_rate: 0.4},
                           ], MasterSetup::CommissionDetail, master_setup_commission_info_id: commission_rate.id)
    
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

