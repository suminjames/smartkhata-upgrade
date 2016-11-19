namespace :ledger do

  def patch_ledger_dailies(ledger)
    fy_codes = [7374]
    branch_id = 1
    fy_codes.each do |fy_code|

      UserSession.selected_branch_id = branch_id
      UserSession.selected_fy_code = fy_code

      ledger_blnc_org = LedgerBalance.unscoped.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id)
      ledger_blnc_cost_center =  LedgerBalance.unscoped.by_branch_fy_code(UserSession.selected_branch_id,fy_code).find_or_create_by!(ledger_id: ledger.id)

      # needed for entering the data balance
      # here we are migrating only single branch so need not concern about the multiple branches
      transaction_dates_org = Particular.unscoped.where(particular_status: 1, ledger_id: ledger.id).order(:transaction_date).pluck(:transaction_date).uniq

      first_daily = true
      opening_balance = 0
      LedgerDaily.by_branch_fy_code(branch_id,fy_code).where(ledger_id: ledger.id).delete_all
      LedgerDaily.by_fy_code_org(fy_code).where(ledger_id: ledger.id).delete_all

      transaction_dates_org.each do |date|
        balance = 0
        total_dr = 0
        total_cr = 0

        # for taking the initial ledger daily balance as opening balance
        if first_daily
          opening_balance = ledger_blnc_cost_center.opening_balance
          first_daily = false
        end

        query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id} AND transaction_date= '#{date}') AS subquery;"
        balance = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f

        # total dr
        query = "SELECT SUM( amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id} AND transaction_date= '#{date}' AND transaction_type = 0"
        dr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f

        query = "SELECT SUM(amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id} AND transaction_date= '#{date}' AND transaction_type = 1"
        cr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f

        if (dr_amount - cr_amount - balance).abs > 0.01
          raise ArgumentError
        end

        daily_report_cost_center = LedgerDaily.by_branch_fy_code(branch_id,fy_code).find_or_create_by!(ledger_id: ledger.id, date: date)
        daily_report_org = LedgerDaily.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id, date: date)

        closing_balance = opening_balance + balance
        daily_report_cost_center.dr_amount = dr_amount
        daily_report_cost_center.cr_amount = cr_amount
        daily_report_cost_center.closing_balance = closing_balance
        daily_report_cost_center.opening_balance = opening_balance
        daily_report_cost_center.save!

        daily_report_org.dr_amount = dr_amount
        daily_report_org.cr_amount = cr_amount
        daily_report_org.closing_balance = closing_balance
        daily_report_org.opening_balance = opening_balance
        daily_report_org.save!

        # closing balance of one is opening of next
        opening_balance = closing_balance
      end
    end
  end

  def patch_closing_balance(ledger)
    fy_code = 7374
    branch_id = 1

    ledger_blnc_org = LedgerBalance.unscoped.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id)
    ledger_blnc_cost_center =  LedgerBalance.unscoped.by_branch_fy_code(UserSession.selected_branch_id,fy_code).find_or_create_by!(ledger_id: ledger.id)

    if ledger_blnc_org.present?
      query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id}) AS subquery;"
      balance = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f
      ledger_blnc_cost_center.closing_balance = balance + ledger_blnc_cost_center.opening_balance

      fy_code = 7374
      query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code}) AS subquery;"
      balance = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f
      ledger_blnc_org.closing_balance = balance + ledger_blnc_org.opening_balance

      ledger_blnc_cost_center.save!
      ledger_blnc_org.save!
      puts "#{ledger.name}"
    end
  end


  task :delete, [:tenant, :id] => :environment do |task,args|
    if args.tenant.present? && args.id.present?
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user = User.first

      voucher = Voucher.find(args.id)
      current_fy_code = voucher.fy_code


      UserSession.selected_branch_id = voucher.branch_id
      UserSession.selected_fy_code= current_fy_code


      ActiveRecord::Base.transaction do

        puts "Task completed "
      end


      Apartment::Tenant.switch!('public')
    else
      puts 'Please pass a tenant and id to the task'
    end
  end

  task :delete_with_wrong_nepse_codes_zero_activity, [:tenant] => :environment do |task,args|
    if args.tenant.present?
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user = User.first
      UserSession.selected_branch_id = 1
      UserSession.selected_fy_code= 7374


      ActiveRecord::Base.transaction do
        count = 0
        Ledger.where('strpos(client_code, chr(9)) > 0').select{ |x| x.closing_balance == 0 &&  x.ledger_dailies.count == 0 }.each do |ledger|
          ledger.client_account.delete
          ledger.delete
          count += 1
        end
        puts "Task completed #{count} records deleted"
      end


      Apartment::Tenant.switch!('public')
    else
      puts 'Please pass a tenant  to the task'
    end
  end

  task :with_wrong_nepse_codes_and_activity_fix, [:tenant] => :environment do |task,args|
    if args.tenant.present?
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user = User.first
      UserSession.selected_branch_id = 1
      UserSession.selected_fy_code= 7374


      ActiveRecord::Base.transaction do
        count = 0
        Ledger.where('strpos(client_code, chr(9)) > 0').select{ |x| x.closing_balance != 0 &&  x.ledger_dailies.count != 0 }.each do |ledger|
          client_account = ledger.client_account
          correct_client_account = ClientAccount.find_by_nepse_code(client_account.nepse_code.gsub(/\t/,''))

          count += 1
        end
        puts "Task completed #{count} records deleted"
      end


      Apartment::Tenant.switch!('public')
    else
      puts 'Please pass a tenant  to the task'
    end
  end




  task :populate_ledger_dailies,[:tenant] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    ActiveRecord::Base.transaction do
      Ledger.find_each do |ledger|
        # fy_codes = [6869, 6970, 7071, 7172, 7273]
        patch_ledger_dailies(ledger)
      end
    end
  end

  task :populate_ledger_dailies_selected,[:tenant, :ledger_ids] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    ledger_ids = args.ledger_ids.split(" ")

    ActiveRecord::Base.transaction do
      Ledger.where(id: ledger_ids).find_each do |ledger|
        # fy_codes = [6869, 6970, 7071, 7172, 7273]
        patch_ledger_dailies(ledger)
        puts "#{ledger.name}"
      end
    end
  end
  task :populate_closing_balance,[:tenant] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    ActiveRecord::Base.transaction do
      Ledger.find_each do |ledger|
        patch_closing_balance(ledger)
      end
    end
  end

  task :populate_closing_balance_selected,[:tenant, :ledger_ids] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    ledger_ids = args.ledger_ids.split(" ")
    ActiveRecord::Base.transaction do
      Ledger.where(id: ledger_ids).find_each do |ledger|
        patch_closing_balance(ledger)
      end
    end
  end

  task :fix_ledger,[:tenant, :ledger_ids] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    ActiveRecord::Base.transaction do
      Ledger.find_each do |ledger|
        patch_ledger_dailies(ledger)
        patch_closing_balance(ledger)
      end
    end
  end

  task :merge_ledgers, [:tenant, :merge_to, :merge_from]=> 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    tenant = args.tenant
    abort 'Please the ledger id to merge to' unless args.merge_to.present?
    abort 'Please the ledger id to merge from' unless args.merge_from.present?

    ledger_to_merge_to = Ledger.find(args.merge_to)
    ledger_to_merge_from = Ledger.find(args.merge_from)
    abort 'Invalid or wrong ledgers' unless args.merge_from.present?

    ActiveRecord::Base.transaction do
      ledger_to_merge_from.particulars.update_all(ledger_id: ledger_to_merge_to.id)
      patch_ledger_dailies(ledger_to_merge_to)
      patch_closing_balance(ledger)
      ledger_to_merge_from.delete
    end
  end
end