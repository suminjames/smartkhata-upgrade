namespace :bill do
  task :change_date,[:tenant, :current_date, :new_date, :bill_type] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    current_date = args.current_date
    new_date = args.new_date
    bill_type = args.bill_type.to_sym
    Accounts::Bills::ChangeDateService.new(current_date, new_date, bill_type: bill_type).process
  end

  # bill:generate_for_sales['trishakti',"201611034023807 201611034023730","2017-08-16"]
  task :generate_for_sales, [:tenant, :contract_numbers] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    current_tenant = Tenant.find_by_name(tenant)
    contract_numbers = args.contract_numbers.split(" ")
    settlement_date = args.settlement_date
    status = GenerateBillsService.new(current_tenant: current_tenant, manual: true, contract_numbers: contract_numbers, skip_voucher: true).process
    puts status
  end
end


