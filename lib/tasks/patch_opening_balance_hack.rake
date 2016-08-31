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
          # "Nepse Sales" => 1,
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