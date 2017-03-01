require "awesome_print"

namespace :client_account do

  desc "Fix name format of all client accounts."
  task :fix_format_of_names,[:tenant, :mimic] => 'smartkhata:validate_tenant' do |task, args|
    count = 0
    ActiveRecord::Base.transaction do
      ClientAccount.unscoped.find_each do |client_account|
        name_before = client_account.name.dup
        if name_before != client_account.format_name
          puts "Processing Client Account(id: #{client_account.id}) with name `#{name_before}`."
          client_account.skip_validation_for_system = true
          client_account.format_name
          client_account.save! unless args.mimic.present?
          count += 1
          puts "Client Account(id: #{client_account.id})'s name changed from `#{name_before}` to `#{client_account.name}`."
        end
      end
      puts "Total Client Account names formatted: #{count}"
    end
  end

  desc "Fix nepse code format of all client accounts."
  task :fix_format_of_nepse_codes,[:tenant, :mimic] => 'smartkhata:validate_tenant' do |task, args|
    count = 0
    ActiveRecord::Base.transaction do
      ClientAccount.unscoped.find_each do |client_account|
        if client_account.nepse_code.present?
          nepse_code_before = client_account.nepse_code.dup
          if nepse_code_before != client_account.format_nepse_code
            puts "Processing Client Account(id: #{client_account.id}) with nepse_code `#{client_account.nepse_code}`."
            client_account.skip_validation_for_system = true
            client_account.format_nepse_code
            client_account.save! unless args.mimic.present?
            count += 1
            puts "Client Account(id: #{client_account.id})'s nepse code changed from `#{nepse_code_before}` to `#{client_account.nepse_code}`."
          end
        end
      end
      puts "Total Client Account nepse codes formatted: #{count}"
    end
  end

  desc "Find client accounts with duplicate (case insensitive) nepse code."
  task :find_client_accounts_with_duplicate_nepse_code,[:tenant, :resolve] => 'smartkhata:validate_tenant' do |task, args|
    resolve = args.resolve == "resolve"
    ActiveRecord::Base.transaction do
      can_be_resolved_automatically_count = 0
      can_not_be_resolved_automatically_count = 0
      resolved_count = 0
      search_hash = ClientAccount.unscoped.select("LOWER(nepse_code)").group("LOWER(nepse_code)").having("count(*) > 1").count

      search_hash.each do |nepse_code, occurrence|
        # Switch the tenant (again) as dependent rake task(s) tend to switch to 'public' tenant at the end.
        Apartment::Tenant.switch!(args.tenant)
        puts "-" * 80
        puts "Nepse code(case-insensitive): #{nepse_code} => Occurence: #{occurrence}"

        client_accounts = ClientAccount.where("UPPER(nepse_code) = ?", nepse_code.upcase).order(id: :asc)

        if client_accounts.size != 2
          puts "CAUTION! Duplicate count for the nepse_code is more than 2."
          can_not_be_resolved_automatically_count += 1
          puts "CAN NOT be resolved automatically!"
        else
          puts "Relevant client account ids: #{client_accounts.map{|r| r.id}.to_s}"
          undeleteable_client_account_count = 0
          client_accounts_have_different_branch = client_accounts.map{|r| r.branch_id}.uniq.size != 1
          client_accounts_have_different_client_type = client_accounts.map{|r| r.client_type}.uniq.size != 1
          if client_accounts.first.updated_at > client_accounts.second.updated_at
            puts "CAUTION! Client accounts' updated_at unexpected behaviour!"
          end
          if client_accounts_have_different_branch
            puts "CAUTION! Client accounts have different branch ids."
            undeleteable_client_account_count = client_accounts.size
          elsif client_accounts_have_different_client_type
            puts "CAUTION! Client accounts have different client types."
            undeleteable_client_account_count = client_accounts.size
          else
            client_accounts.each do |client_account|
              puts "++Inspecing Client account(id: #{client_account.id})..."
              if client_account.ledger.blank?
                puts "CAUTION! Ledger absent!"
              end
              if client_account.boid.present?
                puts "CAUTION! BOID present!"
              end
              if client_account.deletable?(verbose: true)
                puts "Client account(id: #{client_account.id}) OK to delete!"
              else
                undeleteable_client_account_count += 1
                puts "Client account(id: #{client_account.id}) NOT OK to delete!"
              end
            end
          end

          if undeleteable_client_account_count == client_accounts.size
            can_not_be_resolved_automatically_count += 1
            puts "CAN NOT be resolved automatically!"
          else
            can_be_resolved_automatically_count += 1
            puts "CAN be resolved automatically!"
            src_client_account_id_for_merge = nil
            dst_client_account_id_for_merge = nil
            client_accounts.each_with_index do |client_account, index|
              if client_account.deletable?
                unless src_client_account_id_for_merge.present?
                  src_client_account_id_for_merge = client_account.id
                else
                  dst_client_account_id_for_merge = client_account.id
                end
              else
                dst_client_account_id_for_merge = client_account.id
              end
              # ap client_account
            end
            if resolve
              Rake::Task['client_account:merge'].reenable
              Rake::Task['client_account:merge'].invoke(
                  Apartment::Tenant.current,
                  src_client_account_id_for_merge,
                  dst_client_account_id_for_merge
              )
              resolved_count += 1
            end
          end
        end
      end
      puts "=" * 80
      if resolve
        puts "Resolved automatically: #{resolved_count}"
      else
        puts "CAN be resolved automatically: #{can_be_resolved_automatically_count}"
      end
      puts "CAN NOT be resolved automatically: #{can_not_be_resolved_automatically_count}"
    end
    Apartment::Tenant.switch!('public')
  end

  desc "Merge two client accounts"
  # Merges client accounts.
  # If args.force is 'force', it goes forward with the merging even if src_client_account is not 'easily deletable'.
  task :merge,[:tenant, :merge_src_id, :merge_dst_id, :force] => 'smartkhata:validate_tenant' do |task, args|
    include ShareInventoryModule
    unless args.merge_src_id.present? && args.merge_dst_id.present?
      abort 'Invalid arguments'
    end
    merge_client_accounts(args.merge_src_id, args.merge_dst_id, {force: args.force == "force"})
    Apartment::Tenant.switch!('public')
  end

  def merge_client_accounts(src_client_account_id_for_merge, dst_client_account_id_for_merge, force = false)
    puts "Attempting to merge source client_account(id: #{src_client_account_id_for_merge}) to destination client_account(id: #{dst_client_account_id_for_merge})"

    ActiveRecord::Base.transaction do
      src_client_account = ClientAccount.unscoped.find(src_client_account_id_for_merge)
      dst_client_account = ClientAccount.unscoped.find(dst_client_account_id_for_merge)

      # Skip checking for 'deletable?' if force is true.
      if not force
        unless src_client_account.deletable?
          abort 'Source client account (src_client_account) is not easily deletable!'
        end
      end

      # TODO(sarojk) Accomodate transfer of following later.
      unless (src_client_account.group_members.empty? &&
          src_client_account.group_leader.nil? &&
          src_client_account.user.nil? )
        abort("Aborting! Needs manual intervention! Client Account has atleast one of the following: group members, group leader, user, share_inventories")
      end

      # Merge the relevant ledgers
      src_ledger = src_client_account.ledger
      dst_ledger = dst_client_account.ledger
      if dst_ledger.present? && src_ledger.present?
        puts "Attempting to merge destination and source client accounts' ledgers."
        Rake::Task['ledger:merge_ledgers'].reenable
        Rake::Task['ledger:merge_ledgers'].invoke(Apartment::Tenant.current, dst_ledger.id, src_ledger.id )
      elsif dst_ledger.present? && src_ledger.blank?
        puts "Merging of ledgers is not necessary!"
        puts "Source client account doesn't have ledger."
      elsif dst_ledger.blank? && src_ledger.present?
        abort("Aborting! Destination client account doesn't have a ledger")
      elsif dst_ledger.blank? && src_ledger.blank?
        puts "Merging of ledgers is not necessary!"
        puts "Both destination and source client accounts don't have ledger."
      end


      # Transfer client account binding for following models' instances.
      ['Bill', 'ChequeEntry', 'Order', 'Settlement', 'ShareTransaction', 'TransactionMessage'].each do |model|
        model = model.constantize
        model.unscoped.where(client_account_id: src_client_account.id).each do |model_instance|
          puts "Transferring client account association of #{model_instance.class}(id:#{model_instance.id})..."
          model_instance.client_account_id = dst_client_account.id
          model_instance.save!
        end
      end

      # Update share inventories
      src_client_account.share_inventories.each do |share_inventory|
        puts "Adjusting share inventories of src client account to dst client account..."
        quantity = share_inventory
        dst_client_account_share_inventory = ShareInventory.find_or_create_by(
            client_account_id: dst_client_account.id, isin_info_id: share_inventory.isin_info_id
        )
        dst_client_account_share_inventory.lock!
        dst_client_account_share_inventory.total_in += share_inventory.total_in
        dst_client_account_share_inventory.total_out += share_inventory.total_out
        dst_client_account_share_inventory.floorsheet_blnc += share_inventory.floorsheet_blnc
        dst_client_account_share_inventory.save!
        share_inventory.delete
      end

      # Replace attributes in dst with those in src if an attribute in src is not blank.
      [
          "boid",
          "client_type",
          "date",
          "name",
          "address1",
          "address1_perm",
          "address2",
          "address2_perm",
          "address3",
          "address3_perm",
          "city",
          "city_perm",
          "state",
          "state_perm",
          "country",
          "country_perm",
          "phone",
          "phone_perm",
          "customer_product_no",
          "dp_id",
          "dob",
          "sex",
          "nationality",
          "stmt_cycle_code",
          "ac_suspension_fl",
          "profession_code",
          "income_code",
          "electronic_dividend",
          "dividend_curr",
          "email",
          "father_mother",
          "citizen_passport",
          "granfather_father_inlaw",
          "purpose_code_add",
          "add_holder",
          "husband_spouse",
          "citizen_passport_date",
          "citizen_passport_district",
          "pan_no",
          "dob_ad",
          "bank_name",
          "bank_account",
          "bank_address",
          "company_name",
          "company_address",
          "company_id",
          "invited",
          "referrer_name",
          "group_leader_id",
          "branch_id",
          "user_id",
          "mobile_number",
          "ac_code"
      ].each do |key|
        if src_client_account[key].present?
          dst_client_account[key] =  src_client_account[key]
        end
      end

      # Delete the src client account
      src_client_account.delete
      dst_client_account.skip_validation_for_system = true
      dst_client_account.save!

      puts "Resulting destination client account after the merge:"
      puts "-" * 80
      ap dst_client_account
    end
  end

end
