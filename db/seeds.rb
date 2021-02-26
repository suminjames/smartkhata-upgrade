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

def general_klass_setup(attrs, klass, user_id = nil, relation_params = {}, create = true)
  if attrs.is_a? Array
    attrs.map{|attr| user_id.present? ? attr.merge!(relation_params, current_user_id: user_id) : attr.merge!(relation_params) }
  else
    attrs.merge!(relation_params)
  end
  create ? klass.create(attrs) : klass.new(attrs)
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
    user_access_role = UserAccessRole.create(role_type: 1, role_name: "Role-1")
    admin_user_data = @admin_users[count - 1]
    new_user = User.find_or_create_by!(email: admin_user_data[:email]) do |user|
      user.password = admin_user_data[:password]
      user.password_confirmation = admin_user_data[:password]
      user.branch_id = branch.id
      user.user_access_role_id = user_access_role.id
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

    group = general_klass_setup([{name: "Reserve & Surplus", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities']}], Group, current_user_id)
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
                  ], Group, current_user_id,  { parent_id: group.first&.id })

    group = Group.find_by(name: "Direct Income")
    general_klass_setup([
                   {name: "Purchase Commission" },
                   {name: "Sales Commission" }
                 ], Ledger, current_user_id, { group_id: group.id })

    group = general_klass_setup([{name: "Loan", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities'], for_trial_balance: true}], Group, current_user_id)
    general_klass_setup([
                   { name: "Secured Loan"},
                   {name: "Unsecured Loan"}
                 ], Group, current_user_id, { parent_id: group.first&.id })

    group = general_klass_setup([{name: "Current Liabilities", report: Group.reports['Balance'], sub_report: Group.sub_reports['Liabilities'], for_trial_balance: true}], Group, current_user_id)
    general_klass_setup([
                   { name: "Duties & Taxes"},
                   {name: "Sundry Creditors"},
                   {name: "Account Payables"}
                 ], Group, current_user_id, { parent_id: group.first&.id })
    general_klass_setup([
                   {name: "DP Fee/ Transfer"},
                   {name: "Nepse Purchase"},
                   {name: "Nepse Sales"},
                   {name: "Clearing Account"},
                   {name: 'Compliance Fee'}
                 ], Ledger, current_user_id, { group_id: group.first&.id })
    
    group = general_klass_setup([{name: "Current Assets",report: Group.reports['Balance'], sub_report: Group.sub_reports['Assets'], for_trial_balance: true}], Group, current_user_id)
    general_klass_setup([
                   { name: "Advances and Receivables"},
                   {name: "Sundry Debtors"},
                   {name: "Account Receivables"},
                   {name: "Clients"},
                   {name: "Clearing Account"}
                 ], Group, current_user_id, { parent_id: group.first&.id })
    general_klass_setup([
                   {name: "TDS"},
                   {name: "Cash"},
                   {name: 'Close Out'},
                   {name: "Rounding Off Difference"}
                 ], Ledger, current_user_id, { group_id: group.first&.id })

    general_klass_setup([{name: "Nepal Investment Pvt. Ltd", bank_code: "NIBL"},{name: "Global IME ", bank_code: "GIME"}, {name: "Nabil Bank Ltd", bank_code:'NBL'}], Bank, current_user_id)

    puts "populating commission details"  if verbose
    Rake::Task["setup:commission"].execute

    puts " Populating calendar..." if verbose
    Calendar.populate_calendar(current_user_id)

    puts "putting the menus"  if verbose
    MenuItemService.call

  rescue => error
    puts error.message  if verbose
    puts "Tenant #{t.name} exists"  if verbose
  end

  Apartment::Tenant.switch!('public')
end

