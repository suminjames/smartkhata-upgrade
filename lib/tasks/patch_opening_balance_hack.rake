desc "Hack for patching opening balance"
task :patch_internal_opening_balances, [:tenant] => :environment do |task,args|
  if args.tenant.present?
    Apartment::Tenant.switch!(args.tenant)
    UserSession.user= User.first
    UserSession.selected_fy_code= 7374
    UserSession.selected_branch_id = 1

    arr = {
          "Bank:Global IME Bank(7501010000706)" => -31970972.63,
          "Cash" => 39.39,
          "Nepse Purchase" => -81098706.09,
          "Nepse Sales" => 1789927.89,
          # "Purchase Commission" => 1,
          # "Sales Commission" => 1,
        }
    arr.each do |key, value|
      ledger = Ledger.find_by!(name: key)
      if ledger
        ledger_blnc_org = LedgerBalance.by_fy_code_org(UserSession.selected_fy_code).find_or_create_by!(ledger_id: ledger.id)
        ledger_blnc_cost_center =  LedgerBalance.by_branch_fy_code(UserSession.selected_branch_id,UserSession.selected_fy_code).find_or_create_by!(ledger_id: ledger.id)

        amount = value.to_f

        ledger_blnc_org.opening_balance += amount
        ledger_blnc_org.closing_balance += amount
        ledger_blnc_cost_center.opening_balance += amount
        ledger_blnc_cost_center.closing_balance += amount

        ledger_blnc_cost_center.save!
        ledger_blnc_org.save!
      end

    end

    puts "Task completed "
    Apartment::Tenant.switch!('public')
  else
    puts 'Please pass a tenant to the task'
  end
end


task :patch_ledger_dailies, [:tenant] => :environment do |task, args|
  Apartment::Tenant.switch!(args.tenant)
  UserSession.user= User.first
  UserSession.selected_fy_code= 7374
  UserSession.selected_branch_id = 1

  Ledger.all.each do |ledger|
    all_cost_center_dailies = ledger.ledger_dailies.where(branch_id: nil).order('date ASC')
    branch_cost_center_dailies = ledger.ledger_dailies.where(branch_id: 1).order('date ASC')
    opening_balance = 0
    closing_balance = 0
    all_cost_center_dailies.each do |daily|
      if opening_balance == 0
        opening_balance = daily.opening_balance
        closing_balance = daily.closing_balance
      else
        opening_balance = closing_balance
        daily.opening_balance = opening_balance
        closing_balance = opening_balance + daily.dr_amount - daily.cr_amount
        daily.closing_balance = closing_balance
        daily.save!
      end
    end

    opening_balance = 0
    closing_balance = 0
    branch_cost_center_dailies.each do |daily|
      if opening_balance == 0
        opening_balance = daily.opening_balance
        closing_balance = daily.closing_balance
      else
        opening_balance = closing_balance
        daily.opening_balance = opening_balance
        closing_balance = opening_balance + daily.dr_amount - daily.cr_amount
        daily.closing_balance = closing_balance
        daily.save!
      end
    end
  end
  Apartment::Tenant.switch!('public')
end