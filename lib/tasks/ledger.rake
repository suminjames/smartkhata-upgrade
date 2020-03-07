namespace :ledger do
  def patch_ledger_dailies(ledger, all_fiscal_years = false, branch_id = 1, fy_code = nil, current_user_id)
    Accounts::Ledgers::PopulateLedgerDailiesService.new.patch_ledger_dailies(ledger, all_fiscal_years, branch_id, fy_code, current_user_id)
  end

  # for now we are not concerned about multiple branches
  def patch_closing_balance(ledger, all_fiscal_years = false, branch_id = 1, fy_code = current_fy_code, current_user_id)
    Accounts::Ledgers::ClosingBalanceService.new.patch_closing_balance(ledger, all_fiscal_years: all_fiscal_years, branch_id: branch_id, fy_code: fy_code, current_user_id: current_user_id)
  end

  task :delete_with_wrong_nepse_codes_zero_activity, [:tenant, :branch_id, :fy_code]=> 'smartkhata:validate_tenant' do |task,args|
    branch_id = args.branch_id || 1
    fy_code = args.fy_code || current_fy_code

    ActiveRecord::Base.transaction do
      count = 0
      Ledger.unscoped.by_fy_code(fy_code).by_branch_id(branch_id).where('strpos(client_code, chr(9)) > 0').select{ |x| x.closing_balance == 0 &&  x.ledger_dailies.count == 0 }.each do |ledger|
        ledger.client_account.delete
        ledger.delete
        count += 1
      end
      puts "Task completed #{count} records deleted"
    end
  end

  task :populate_ledger_dailies,[:tenant, :all_fiscal_year, :branch_id, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    branch_id = args.branch_id || 1
    fy_code = args.fy_code || current_fy_code
    all_fiscal_year = args.all_fiscal_year == 'true' ? true : false
    ActiveRecord::Base.transaction do
      count = 0
      Ledger.find_each do |ledger|
        count += 1
        patch_ledger_dailies(ledger, all_fiscal_year, branch_id, fy_code, current_user_id)
        puts "#{count} ledgers processed"
      end
    end
    puts "completed ledger dailies"
  end

  task :populate_ledger_dailies_selected,[:tenant, :ledger_ids, :branch_id, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    branch_id = args.branch_id || 1
    fy_code = args.fy_code || current_fy_code
    ledger_ids = args.ledger_ids.split(" ")

    ActiveRecord::Base.transaction do
      Ledger.where(id: ledger_ids).find_each do |ledger|
        patch_ledger_dailies(ledger, false, branch_id, fy_code, current_user_id)
        puts "#{ledger.name}"
      end
    end
  end
  task :populate_closing_balance,[:tenant, :all_fiscal_year, :branch_id, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    branch_id = args.branch_id || 1
    fy_code = args.fy_code || current_fy_code
    all_fiscal_year = args.all_fiscal_year == 'true' ? true : false
    ActiveRecord::Base.transaction do
      Ledger.find_each do |ledger|
        patch_closing_balance(ledger, all_fiscal_year, branch_id, fy_code, current_user_id)
      end
    end
  end

  task :populate_closing_balance_selected,[:tenant, :ledger_ids, :branch_id, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    branch_id = args.branch_id || 1
    fy_code = args.fy_code || current_fy_code
    ledger_ids = args.ledger_ids.split(" ")
    ActiveRecord::Base.transaction do
      Ledger.where(id: ledger_ids).find_each do |ledger|
        patch_closing_balance(ledger, false, branch_id, fy_code, current_user_id)
      end
    end
  end

  # Fixes all ledgers
  task :fix_ledger_all,[:tenant, :all_fiscal_years, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    all_fiscal_years = args.all_fiscal_years == 'true' ? true : false
    fy_code = args.fy_code || current_fy_code
    ActiveRecord::Base.transaction do
      Branch.all.each do |branch|
        branch_id = branch.id
        Ledger.find_each do |ledger|
          patch_ledger_dailies(ledger, all_fiscal_years, branch_id, fy_code, current_user_id)
          patch_closing_balance(ledger, all_fiscal_years, branch_id, fy_code, current_user_id)
        end
      end
    end
  end

  # Example syntax:
  # ledger:fix_ledger_selected['trishakti',"3405 11938"]
  task :fix_ledger_selected,[:tenant, :ledger_ids, :all_fiscal_years, :branch_id, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    branch_id = args.branch_id || 1
    fy_code = args.fy_code || current_fy_code
    ledger_ids = args.ledger_ids.split(" ")
    all_fiscal_years = args.all_fiscal_years == 'true' ? true : false
    ActiveRecord::Base.transaction do
      Ledger.where(id: ledger_ids).find_each do |ledger|
        patch_ledger_dailies(ledger, all_fiscal_years, branch_id, fy_code, current_user_id )
        patch_closing_balance(ledger, all_fiscal_years, branch_id, fy_code, current_user_id )
      end
    end
  end

  task :merge, [:tenant, :merge_to, :merge_from]=> 'smartkhata:validate_tenant' do |task, args|
    abort 'Please pass the ledger id to merge to' unless args.merge_to.present?
    abort 'Please pass the ledger id to merge from' unless args.merge_from.present?
    Accounts::Ledgers::Merge.new(args.merge_to, args.merge_from, User.admin.first).call
  end

  desc "Fix name format of all ledgers."
  task :fix_format_of_names,[:tenant, :mimic] => 'smartkhata:validate_tenant' do |task, args|
    count = 0
    ActiveRecord::Base.transaction do
      Ledger.find_each do |ledger|
        name_before = ledger.name.dup
        if name_before != ledger.format_name
          puts "Processing Ledger(id: #{ledger.id}) with name `#{ledger.name}`."
          ledger.format_name
          ledger.current_user_id = current_user_id
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
      Ledger.find_each do |ledger|
        if ledger.client_code.present?
          client_code_before = ledger.client_code.dup
          if client_code_before != ledger.format_client_code
            puts "Processing Ledger(id: #{ledger.id}) with client_code `#{ledger.client_code}`."
            ledger.format_client_code
            ledger.current_user_id = current_user_id
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
    search_hash = Ledger.select("LOWER(client_code)").group("trim(regexp_replace(LOWER(client_code), '\\s+', ' ', 'g'))").having("count(*) > 1").count

    client_hash = ClientAccount.select("LOWER(nepse_code)").group("trim(regexp_replace(LOWER(nepse_code), '\\s+', ' ', 'g'))").having("count(*) > 1").count

    search_hash.each {|client_code, occurrence| p "#{client_code} => #{occurrence}"}
    client_hash.each {|client_code, occurrence| p "#{client_code} => #{occurrence}"}
    puts search_hash.size
    puts client_hash.size
  end

  task :merge_ledgers_with_duplicate_client_code,[:tenant, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    fy_code = args[:fy_code]
    client_codes = Ledger.unscoped.select("LOWER(client_code)").group("trim(regexp_replace(LOWER(client_code), '\\s+', ' ', 'g'))").having("count(*) > 1").count.keys.uniq
    client_codes.compact.each do |client_code|
      ledger_to_merge_from = Ledger.unscoped.where("lower(client_code) = '#{client_code}'").first
      ledger_to_merge_to = Ledger.unscoped.where("trim(regexp_replace(LOWER(client_code), '\\s+', ' ', 'g')) = '#{client_code}'").where.not(id: ledger_to_merge_from.id).first

      particulars_count = Particular.unscoped.where(ledger_id: ledger_to_merge_from.id).where.not(fy_code: fy_code).count
      mandala_mapping_for_deleted_ledger = Mandala::ChartOfAccount.where(ledger_id: ledger_to_merge_from).first
      mandala_mapping_for_remaining_ledger = Mandala::ChartOfAccount.where(ledger_id: ledger_to_merge_to).first

      if ledger_to_merge_from.opening_balance != 0 || particulars_count > 0 || (mandala_mapping_for_deleted_ledger.present? && mandala_mapping_for_remaining_ledger.present?)
        next
      end

      Rake::Task["ledger:merge_ledgers"].invoke(tenant, ledger_to_merge_to.id, ledger_to_merge_from.id, true)
      Rake::Task["ledger:merge_ledgers"].reenable
    end
  end


  # take file from trishakti with duplicate names and merge them
  task :merge_ledgers_with_duplicate_name,[:tenant, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    fy_code = args.fy_code || current_fy_code

    dir = "#{Rails.root}/test_files/"
    file_with_duplicate_ledger = dir + 'duplicate_ledger.csv'
    ledger_array = []
    csv_text = File.read(file_with_duplicate_ledger)
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      ledger_array << row.to_hash["ledger"]
    end
    count_cant_solve = 0
    count_solved = 0
    count_already_solved = 0
    solved_ledgers = []
    unsolved_ledgers = []

    ledger_array.uniq.each do |ledger_name|

      ledgers = Ledger.where("trim(regexp_replace(name, '\\s+', ' ', 'g')) ilike ?", ledger_name.squish)

      unique_client_count = ledgers.pluck(:client_code).compact.size
      if unique_client_count > 1
        # puts ledger_name
        count_cant_solve += 1
      elsif ledgers.size > 1
        ledger_to_consider = ledgers.detect{|x| x.opening_balance != 0}
        unless ledger_to_consider
          ledger_to_consider = ledgers.detect{|x| Particular.where(ledger_id: x.id).where.not(fy_code: fy_code).count > 1}

          unless ledger_to_consider
            ledger_to_consider = ledgers.detect{|x| x.client_code.present? }
          end
        end

        ledgers_to_merge = ledgers.select{|x| x unless x.id == ledger_to_consider.id }

        if ledgers_to_merge.size != 1
          unsolved_ledgers << ledger_to_consider.name
          next
        end

        merge_ledger = ledgers_to_merge.first

        particulars_count = Particular.where(ledger_id: merge_ledger.id).where.not(fy_code: fy_code).count
        if particulars_count > 0
          raise "Has previous fy data"
        end

        override_fy_code = merge_ledger.client_code.present? ? true : false
        solved_ledgers << ledger_to_consider.name

        Rake::Task["ledger:merge_ledgers"].invoke(tenant, ledger_to_consider.id, merge_ledger.id, override_fy_code)
        Rake::Task["ledger:merge_ledgers"].reenable
      else
        count_solved += 1
      end
    end

    puts "#{count_cant_solve} ambiguous out of #{ledger_array.uniq.size}"
    puts "#{count_solved} already solved out of #{ledger_array.uniq.size}"
    puts "unsolved ledgers due to multiple"
    puts unsolved_ledgers.join(',')
    puts "solved ledgers"
    puts solved_ledgers.join(',')
  end

  task :pull_opening_balance,[:tenant, :branch] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    branch = args.branch
    Accounts::Ledgers::PullOpeningBalanceService.new(branch_id: branch).process
  end

  desc 'move particulars to one branch for a ledger id'
  task :move_particulars,[:tenant, :ledger_id, :branch_id, :user_id, :dry_run, :date_bs] => 'smartkhata:validate_tenant' do |task, args|
    abort 'Please pass tenant, ledger_id, branch_id, dry_run, date_bs' if (args.ledger_id.blank? || args.branch_id.blank?)
    client_account = Ledger.find(args.ledger_id).client_account
    dry_run = args.dry_run === 'false' ? false : true;
    if (client_account)
      Accounts::Branches::ClientBranchService.new.patch_client_branch(client_account, args.branch_id, args.date_bs, dry_run, args.user_id)
    end
  end

  #   patch opening balance based on file
  task :patch_opening_balance, [:tenant, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    include ApplicationHelper

    tenant = args.tenant
    fy_code = args.fy_code || current_fy_code
    dir = "#{Rails.root}/tmp/files/"
    opening_balance_patch = dir + 'opening_balance_patch.csv'
    ledger_array = []
    csv_text = File.read(opening_balance_patch)
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      ledgers = Ledger.where('lower(name) = ?', row.to_hash["ledger"].downcase)
      hash = row.to_hash
      if ledgers.size > 1
        found_ledgers = []
        ledgers.each do |ledger|
          lbs = LedgerBalance.where(fy_code: fy_code, ledger_id: ledger.id, branch_id: nil)
          if lbs.size == 1
            lb= lbs.first
            old_dr = hash['old_dr'].to_f
            old_cr = hash['old_cr'].to_f * -1
            if (lb.opening_balance == 0 && old_dr == old_cr && old_dr == 0) ||
              (lb.opening_balance > 0 && equal_amounts?(lb.opening_balance, old_dr)) ||
              (lb.opening_balance < 0 && equal_amounts?(lb.opening_balance, old_cr))
              found_ledgers << ledger
            end
          end
        end
        puts row.to_hash["ledger"] if found_ledgers.size != 1
        if found_ledgers.size == 1
          hash[:ledger_id] = found_ledgers.first.id
          ledger_array << hash
        end
      elsif ledgers.size == 0
        puts row.to_hash["ledger"]
      else
        hash[:ledger_id] = ledgers.first.id
        ledger_array << hash
      end
    end

    ledger_ids = []
    ActiveRecord::Base.transaction do
      ledger_array.each do |ledger_hash|
        ledger = Ledger.find(ledger_hash[:ledger_id])
        branch_ids = [nil]
        branch_id = ledger.client_account&.branch_id || 1
        branch_ids << branch_id

        opening_balance = 0
        if ledger_hash['new_dr'].to_f == 0 &&  ledger_hash['new_cr'].to_f != 0
          opening_balance = ledger_hash['new_cr'].to_f * -1
          opening_balance_type = 1
        else
          opening_balance = ledger_hash['new_dr'].to_f
          opening_balance_type = 0
        end


        ledger_balances = LedgerBalance.where(ledger_id: ledger.id, fy_code: fy_code, branch_id: branch_ids)
        if ledger_balances.size != 2
          ledger_balance_ids = []
          branch_ids.each do |branch_id|
            ledger_balance_ids << LedgerBalance.find_or_create_by(ledger_id: ledger.id, fy_code: fy_code, branch_id: branch_id).id
          end
          ledger_balances = LedgerBalance.where(id: ledger_balance_ids)
        end

        ledger_balances.update_all(opening_balance: opening_balance, opening_balance_type: opening_balance_type)
        ledger_ids << ledger.id
      end

      Branch.all.pluck(:id).each do |branch_id|
        Accounts::Ledgers::PopulateLedgerDailiesService.new.process(ledger_ids.uniq, false, branch_id)
        Accounts::Ledgers::ClosingBalanceService.new.process(ledger_ids.uniq, false, branch_id)
      end
    end
  end

  task :ledger_count, [:tenant, :branch_id, :fy_code, :dry_run]=> 'smartkhata:validate_tenant' do |task, args|
    include FiscalYearModule
    branch_id = args.branch_id || 0
    fy_code = args.fy_code || get_fy_code
    ledger_count = 0
    ledger_ids = []
    Ledger.find_each do |ledger|
      ledger_daily_last = LedgerDaily.where(ledger_id: ledger.id, branch_id: branch_id, fy_code: fy_code).last
      ledger_balance =  LedgerBalance.where(ledger_id: ledger.id, branch_id: branch_id, fy_code: fy_code).last

      if ledger_daily_last != nil
        if ledger_daily_last.closing_balance != ledger_balance.closing_balance
          ledger_count+=1
          ledger_ids << ledger.id
        end
      end
    end

    if args.dry_run === 'true'
      puts "#{ledger_count}"
      puts "ledger_ids:#{ledger_ids.join(',')}"
    end
  end

  task :wrong_cost_center_opening_balance, [:tenant, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    fy_code = args.fy_code

    ledger_ids = LedgerBalance.where(fy_code: fy_code).where('opening_balance <> 0').pluck(:ledger_id).uniq

    errorneus_ledger_ids = []

    ledger_ids.each do |ledger_id|
      org_balance = LedgerBalance.where(fy_code: fy_code, ledger_id: ledger_id).where(branch_id: nil).sum(:opening_balance)
      sum_of_cost_center = LedgerBalance.where(fy_code: fy_code, ledger_id: ledger_id).where.not(branch_id: nil).sum(:opening_balance)
      unless (org_balance.to_d - sum_of_cost_center.to_d).abs <= 0.01
        errorneus_ledger_ids << ledger_id
      end
    end

    puts "Wrong Ledgers: #{errorneus_ledger_ids.size}"
    puts "Ledger ids : #{errorneus_ledger_ids.join(', ')}"
    puts "#{Ledger.where(id: errorneus_ledger_ids).pluck(:name).join(', ')}"
  end
end
