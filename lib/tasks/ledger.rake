namespace :ledger do

  def patch_ledger_dailies(ledger, all_fiscal_years = false)
    # need to modify this in future to accomodate current fiscal year
    if all_fiscal_years
      fy_codes = [6869, 6970, 7071, 7273, 7374]
    else
      fy_codes = [7374]
    end

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

  # for now we are not concerned about multiple branches
  def patch_closing_balance(ledger, all_fiscal_years = false)
    if all_fiscal_years
      fy_codes = [6869, 6970, 7071, 7273, 7374]
    else
      fy_codes = [7374]
    end
    branch_id = 1

    fy_codes.each do |fy_code|
      ledger_blnc_org = LedgerBalance.unscoped.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id)
      ledger_blnc_cost_center =  LedgerBalance.unscoped.by_branch_fy_code(UserSession.selected_branch_id,fy_code).find_or_create_by!(ledger_id: ledger.id)

      if ledger_blnc_org.present?
        query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id}) AS subquery;"
        balance = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f

        query = "SELECT SUM( amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id}  AND transaction_type = 0"
        dr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f

        query = "SELECT SUM(amount) FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code} AND branch_id= #{branch_id} AND transaction_type = 1"
        cr_amount = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f



        ledger_blnc_cost_center.closing_balance = balance + ledger_blnc_cost_center.opening_balance
        ledger_blnc_cost_center.dr_amount = dr_amount
        ledger_blnc_cost_center.cr_amount = cr_amount


        fy_code = 7374
        query = "SELECT SUM(subquery.amount) FROM (SELECT ( CASE WHEN transaction_type = 0 THEN amount ELSE amount * -1 END ) as amount FROM particulars WHERE ledger_id = #{ledger.id} AND particular_status = 1 AND fy_code = #{fy_code}) AS subquery;"
        balance = ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_f
        ledger_blnc_org.closing_balance = balance + ledger_blnc_org.opening_balance
        ledger_blnc_org.dr_amount = dr_amount
        ledger_blnc_org.cr_amount = cr_amount

        ledger_blnc_cost_center.save!
        ledger_blnc_org.save!
        puts "#{ledger.name}"
      end
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




  task :populate_ledger_dailies,[:tenant, :all_fiscal_year] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    all_fiscal_year = args.all_fiscal_year == 'true' ? true : false
    ActiveRecord::Base.transaction do
      count = 0
      Ledger.find_each do |ledger|
        count += 1
        # fy_codes = [6869, 6970, 7071, 7172, 7273]
        patch_ledger_dailies(ledger, all_fiscal_year)
        puts "#{count} ledgers processed"
      end
    end
    puts "completed ledger dailies"
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
  task :populate_closing_balance,[:tenant, :all_fiscal_year] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    all_fiscal_year = args.all_fiscal_year == 'true' ? true : false
    ActiveRecord::Base.transaction do
      Ledger.find_each do |ledger|
        patch_closing_balance(ledger, all_fiscal_year)
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

  # Fixes all ledgers
  task :fix_ledger_all,[:tenant] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    ActiveRecord::Base.transaction do
      Ledger.find_each do |ledger|
        patch_ledger_dailies(ledger)
        patch_closing_balance(ledger)
      end
    end
  end

  # Example syntax:
  # ledger:fix_ledger_selected['trishakti',"3405 11938"]
  task :fix_ledger_selected,[:tenant, :ledger_ids] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    ledger_ids = args.ledger_ids.split(" ")
    ActiveRecord::Base.transaction do
      Ledger.where(id: ledger_ids).find_each do |ledger|
        patch_ledger_dailies(ledger)
        patch_closing_balance(ledger)
      end
    end
  end

  task :merge_ledgers, [:tenant, :merge_to, :merge_from]=> 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    tenant = args.tenant
    abort 'Please pass the ledger id to merge to' unless args.merge_to.present?
    abort 'Please pass the ledger id to merge from' unless args.merge_from.present?

    ledger_to_merge_to = Ledger.find(args.merge_to)
    ledger_to_merge_from = Ledger.find(args.merge_from)
    abort 'Invalid or wrong ledgers' unless args.merge_from.present?

    ActiveRecord::Base.transaction do
      ledger_to_merge_from.particulars.update_all(ledger_id: ledger_to_merge_to.id)


      LedgerBalance.unscoped.where(ledger_id: ledger_to_merge_from.id).delete_all
      LedgerDaily.unscoped.where(ledger_id: ledger_to_merge_from.id).delete_all

      ledger_to_merge_from.delete

      patch_ledger_dailies(ledger_to_merge_to)
      patch_closing_balance(ledger_to_merge_to)

      mandala_mapping_for_deleted_ledger = Mandala::ChartOfAccount.where(ledger_id: ledger_to_merge_from).first
      mandala_mapping_for_remaining_ledger = Mandala::ChartOfAccount.where(ledger_id: ledger_to_merge_to).first

      if mandala_mapping_for_deleted_ledger.present? && mandala_mapping_for_remaining_ledger.present?
        abort 'Need manual Intervention'
      elsif mandala_mapping_for_deleted_ledger.present?
        mandala_mapping_for_deleted_ledger.ledger_id = args.merge_to
        mandala_mapping_for_deleted_ledger.save!
      end

      #   current implementation does not account for the client acccount
      #   and also the chart of account and the mandala mapping

    end
  end

  desc "Fix name format of all ledgers."
  task :fix_format_of_names,[:tenant, :mimic] => 'smartkhata:validate_tenant' do |task, args|
    count = 0
    ActiveRecord::Base.transaction do
      Ledger.unscoped.find_each do |ledger|
        name_before = ledger.name.dup
        if name_before != ledger.format_name
          puts "Processing Ledger(id: #{ledger.id}) with name `#{ledger.name}`."
          ledger.format_name
          ledger.save! unless args.mimic.present?
          count += 1
          puts "Ledger(id: #{ledger.id})'s name changed from `#{name_before}` to `#{ledger.name}`."
        end
      end
      puts "Total Ledger names formatted: #{count}"
    end
  end

  desc "Fix client code format of all ledgers."
  task :fix_format_of_client_codes,[:tenant, :mimic] => 'smartkhata:validate_tenant' do |task, args|
    count = 0
    ActiveRecord::Base.transaction do
      Ledger.unscoped.find_each do |ledger|
        if ledger.client_code.present?
          client_code_before = ledger.client_code.dup
          if client_code_before != ledger.format_client_code
            puts "Processing Ledger(id: #{ledger.id}) with client_code `#{ledger.client_code}`."
            ledger.format_client_code
            ledger.save! unless args.mimic.present?
            count += 1
            puts "Ledger(id: #{ledger.id})'s client code changed from `#{client_code_before}` to `#{ledger.client_code}`."
          end
        end
      end
      puts "Total Ledger client codes formatted: #{count}"
    end
  end

  desc "Find ledgers with duplicate (case insensitive) client code."
  task :find_ledgers_with_duplicate_client_code,[:tenant] => 'smartkhata:validate_tenant' do |task, args|
    search_hash = Ledger.unscoped.select("LOWER(client_code)").group("LOWER(client_code)").having("count(*) > 1").count
    search_hash.each do |client_code, occurrence|
      p "#{client_code} => #{occurrence}"
    end
  end

end