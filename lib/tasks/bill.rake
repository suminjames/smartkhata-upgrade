namespace :bill do
  task :change_date,[:tenant, :current_date, :new_date, :bill_type, :branch_id, :fy_code, :user_id] => 'smartkhata:validate_tenant' do |task, args|
    include FiscalYearModule
    tenant = args.tenant
    current_date = args.current_date
    new_date = args.new_date
    bill_type = args.bill_type.to_sym
    branch_id = args.branch_id || 1
    fy_code = args.fy_code || get_fy_code
    current_user_id = args.user_id || User.where(role: 4).first.id
    Accounts::Bills::ChangeDateService.new(current_date, new_date, bill_type: bill_type, branch_id: branch_id, current_user_id: current_user_id).process
  end

  # bill:generate_for_sales['trishakti',"201611034023807 201611034023730",true]
  task :generate_for_sales, [:tenant, :contract_numbers, :skip_voucher] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    current_tenant = Tenant.find_by_name(tenant)
    contract_numbers = args.contract_numbers.split(" ")
    skip_voucher = args.skip_voucher || false
    settlement_date = args.settlement_date
    status = GenerateBillsService.new(current_tenant: current_tenant, manual: true, contract_numbers: contract_numbers, skip_voucher: skip_voucher).process
    puts status
  end
end


