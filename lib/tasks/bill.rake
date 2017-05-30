namespace :bill do
  task :change_date,[:tenant, :current_date, :new_date, :bill_type] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    current_date = args.current_date
    new_date = args.new_date
    bill_type = args.bill_type.to_sym
    Accounts::Bills::ChangeDateService.new(current_date, new_date, bill_type: bill_type).process
  end
end


