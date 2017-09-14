namespace :ledger do

  def all_fy_codes
    return [6869, 6970, 7071, 7273, 7374, 7475]
  end

  def current_fy_code
    return 7475
  end

  def patch_ledger_dailies(ledger, all_fiscal_years = false, branch_id = 1, fy_code = nil)
    Accounts::Ledgers::PopulateLedgerDailiesService.new.patch_ledger_dailies(ledger, all_fiscal_years, branch_id, fy_code)
  end

  # for now we are not concerned about multiple branches
  def patch_closing_balance(ledger, all_fiscal_years = false, branch_id = 1, fy_code = current_fy_code)
    Accounts::Ledgers::ClosingBalanceService.new.patch_closing_balance(ledger, all_fiscal_years: all_fiscal_years, branch_id: branch_id, fy_code: fy_code)
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
  task :fix_ledger_all,[:tenant, :all_fiscal_years] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    all_fiscal_years = args.all_fiscal_years || false
    ActiveRecord::Base.transaction do
      Branch.all.each do |branch|
        Ledger.find_each do |ledger|
          patch_ledger_dailies(ledger, all_fiscal_years, branch.id)
          patch_closing_balance(ledger, all_fiscal_years, branch.id)
        end
      end
    end
  end

  # Example syntax:
  # ledger:fix_ledger_selected['trishakti',"3405 11938"]
  task :fix_ledger_selected,[:tenant, :ledger_ids, :all_fiscal_year, :branch_id] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    branch_id = args.branch_id || 1
    ledger_ids = args.ledger_ids.split(" ")
    all_fiscal_year = args.all_fiscal_year == 'true' ? true : false
    ActiveRecord::Base.transaction do
      Ledger.where(id: ledger_ids).find_each do |ledger|
        patch_ledger_dailies(ledger, all_fiscal_year, branch_id )
        patch_closing_balance(ledger, all_fiscal_year, branch_id)
      end
    end
  end

  task :merge_ledgers, [:tenant, :merge_to, :merge_from, :override_nepse_code]=> 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    abort 'Please pass the ledger id to merge to' unless args.merge_to.present?
    abort 'Please pass the ledger id to merge from' unless args.merge_from.present?

    ledger_to_merge_to = Ledger.find(args.merge_to)
    ledger_to_merge_from = Ledger.find(args.merge_from)
    all_fiscal_year = true
    override_nepse_code = args.override_nepse_code || false
    abort 'Invalid or wrong ledgers' unless args.merge_from.present?
    abort 'Ledger has opening balance' if ledger_to_merge_from.opening_balance > 0

    ActiveRecord::Base.transaction do
      particulars = Particular.unscoped.where(ledger_id: ledger_to_merge_from.id)

      if particulars.pluck(:fy_code).uniq.size != 0 && ( particulars.pluck(:fy_code).uniq.size > 1 || particulars.pluck(:fy_code).uniq.first != current_fy_code )
        abort 'Need manual Intervention. It has previous fiscal year data'
      end
      particulars.update_all(ledger_id: ledger_to_merge_to.id)

      LedgerBalance.unscoped.where(ledger_id: ledger_to_merge_from.id).delete_all
      LedgerDaily.unscoped.where(ledger_id: ledger_to_merge_from.id).delete_all

      patch_ledger_dailies(ledger_to_merge_to, all_fiscal_year)
      patch_closing_balance(ledger_to_merge_to, all_fiscal_year)

      mandala_mapping_for_deleted_ledger = Mandala::ChartOfAccount.where(ledger_id: ledger_to_merge_from).first
      mandala_mapping_for_remaining_ledger = Mandala::ChartOfAccount.where(ledger_id: ledger_to_merge_to).first

      # delete client accounts too
      client_account_to_persist = ledger_to_merge_to.client_account
      client_account_to_delete = ledger_to_merge_from.client_account
      if client_account_to_delete
        if client_account_to_persist && client_account_to_persist != client_account_to_delete
          client_account_to_persist.mobile_number ||= client_account_to_delete.mobile_number
          client_account_to_persist.email ||= client_account_to_delete.email
          client_account_to_persist.skip_validation_for_system = true
          nepse_code = client_account_to_delete.nepse_code
          if override_nepse_code
            abort 'no nepse code' if nepse_code.blank?
            client_account_to_persist.nepse_code = nepse_code
            ledger_to_merge_to.client_code = nepse_code
          end
          TransactionMessage.where(client_account_id: client_account_to_delete.id).update_all(client_account_id: client_account_to_persist.id)
          ShareTransaction.unscoped.where(client_account_id: client_account_to_delete.id).update_all(client_account_id: client_account_to_persist.id)
          Bill.unscoped.where(client_account_id: client_account_to_delete.id).update_all(client_account_id: client_account_to_persist.id)
          Settlement.unscoped.where(client_account_id: client_account_to_delete.id).update_all(client_account_id: client_account_to_persist.id)
          ChequeEntry.unscoped.where(client_account_id: client_account_to_delete.id).update_all(client_account_id: client_account_to_persist.id)

          client_account_to_delete.delete

          client_account_to_persist.name = client_account_to_persist.name.squish
          client_account_to_persist.nepse_code = client_account_to_persist.nepse_code.squish
          client_account_to_persist.save!
        else
          ledger_to_merge_to.client_account = client_account_to_delete
        end
      end

      ledger_to_merge_from.delete

      ledger_to_merge_to.client_code = ledger_to_merge_to.client_code.to_s.squish
      ledger_to_merge_to.name = ledger_to_merge_to.name.to_s.squish
      ledger_to_merge_to.save!

      if mandala_mapping_for_deleted_ledger.present? && mandala_mapping_for_remaining_ledger.present?
        abort 'Need manual Intervention both have relation to mandala'
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

    search_hash = Ledger.unscoped.select("LOWER(client_code)").group("trim(regexp_replace(LOWER(client_code), '\\s+', ' ', 'g'))").having("count(*) > 1").count

    client_hash = ClientAccount.unscoped.select("LOWER(nepse_code)").group("trim(regexp_replace(LOWER(nepse_code), '\\s+', ' ', 'g'))").having("count(*) > 1").count

    search_hash.each {|client_code, occurrence| p "#{client_code} => #{occurrence}"}
    client_hash.each {|client_code, occurrence| p "#{client_code} => #{occurrence}"}
    puts search_hash.size
    puts client_hash.size
  end

  task :merge_ledgers_with_duplicate_client_code,[:tenant] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    client_codes = Ledger.unscoped.select("LOWER(client_code)").group("trim(regexp_replace(LOWER(client_code), '\\s+', ' ', 'g'))").having("count(*) > 1").count.keys.uniq
    client_codes.compact.each do |client_code|
      ledger_to_merge_from = Ledger.unscoped.where("lower(client_code) = '#{client_code}'").first
      ledger_to_merge_to = Ledger.unscoped.where("trim(regexp_replace(LOWER(client_code), '\\s+', ' ', 'g')) = '#{client_code}'").where.not(id: ledger_to_merge_from.id).first

      particulars_count = Particular.unscoped.where(ledger_id: ledger_to_merge_from.id).where.not(fy_code: UserSession.selected_fy_code).count
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
  task :merge_ledgers_with_duplicate_name,[:tenant] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant

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
          ledger_to_consider = ledgers.detect{|x| Particular.unscoped.where(ledger_id: x.id).where.not(fy_code: UserSession.selected_fy_code).count > 1}

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

        particulars_count = Particular.unscoped.where(ledger_id: merge_ledger.id).where.not(fy_code: UserSession.selected_fy_code).count
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
end