namespace :ledger do
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
end