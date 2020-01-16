namespace :ledger_alt do

  def current_fy_code
    include FiscalYearModule
    return FiscalYearModule::get_fy_code
  end

  task :populate_ledger_dailies,[:tenant, :all_fiscal_year, :user_id, :branch_id, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    include FiscalYearModule

    current_user_id = args.user_id || User.admin.first.id
    branch_id = args.branch_id || 1
    fy_code = args.fy_code || current_fy_code
    all_fiscal_year = args.all_fiscal_year == 'true' ? true : false

    ActiveRecord::Base.transaction do
      count = 0
      Ledger.by_branch_id(branch_id).by_fy_code(fy_code).find_each do |ledger|
        count += 1
        # fy_codes = [6869, 6970, 7071, 7172, 7273]
        patch_ledger_dailies(ledger, all_fiscal_year, branch_id, fy_code, current_user_id)
        puts "#{count} ledgers processed"
      end
    end
    puts "completed ledger dailies"
  end

  task :populate_ledger_dailies_selected,[:tenant, :ledger_ids, :user_id, :branch_id, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    include FiscalYearModule

    ledger_ids = args.ledger_ids.split(" ")
    current_user_id = args.user_id || User.admin.first.id
    branch_id = args.branch_id || 1
    fy_code = args.fy_code || current_fy_code

    ActiveRecord::Base.transaction do
      Ledger.where(id: ledger_ids).find_each do |ledger|
        patch_ledger_dailies(ledger, false, branch_id, fy_code, current_user_id)
        puts "#{ledger.name}"
      end
    end
  end
  task :populate_closing_balance,[:tenant, :all_fiscal_year, :user_id, :branch_id, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    current_user_id = args.user_id || User.admin.first.id
    branch_id = args.branch_id || 1
    fy_code = args.fy_code || current_fy_code
    all_fiscal_year = args.all_fiscal_year == 'true' ? true : false
    ActiveRecord::Base.transaction do
      Ledger.find_each do |ledger|
        patch_closing_balance(ledger, all_fiscal_year, branch_id, fy_code, current_user_id)
      end
    end
  end

  task :populate_closing_balance_selected,[:tenant, :ledger_ids, :user_id, :branch_id, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    current_user_id = args.user_id || User.admin.first.id
    branch_id = args.branch_id || 1
    fy_code = args.fy_code || current_fy_code

    ledger_ids = args.ledger_ids.split(" ")
    ActiveRecord::Base.transaction do
      Ledger.where(id: ledger_ids).find_each do |ledger|
        patch_closing_balance(ledger, false, branch_id, fy_code, current_user_id)
      end
    end
  end

  # Example syntax:
  # ledger:fix_ledger_selected['trishakti',"3405 11938"]
  task :fix_ledger_selected,[:tenant, :ledger_ids, :all_fiscal_year, :user_id, :branch_id, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    current_user_id = args.user_id || User.admin.first.id
    branch_id = args.branch_id || 1
    fy_code = args.fy_code || current_fy_code

    ledger_ids = args.ledger_ids.split(" ")
    all_fiscal_year = args.all_fiscal_year == 'true' ? true : false

    ActiveRecord::Base.transaction do
      Ledger.where(id: ledger_ids).find_each do |ledger|
        patch_ledger_dailies(ledger, all_fiscal_year, branch_id, fy_code, current_user_id )
        patch_closing_balance(ledger, all_fiscal_year, branch_id, fy_code, current_user_id)
      end
    end
  end

end