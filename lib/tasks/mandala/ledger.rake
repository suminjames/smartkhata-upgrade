namespace :mandala do
  desc "patch opening balance"
  task :setup_opening_balances,[:tenant] => 'mandala:validate_tenant' do |task,args|
    tenant = args.tenant

    Mandala::AccountBalance.all.each do |balance|
      ledger = balance.chart_of_account.ledger
      fy_code = balance.fy_code
      if ledger
        ledger_blnc_org = LedgerBalance.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id)
        ledger_blnc_cost_center =  LedgerBalance.by_branch_fy_code(UserSession.selected_branch_id,fy_code).find_or_create_by!(ledger_id: ledger.id)

        amount = balance.nrs_balance_amount.to_f

        ledger_blnc_org.opening_balance += amount
        ledger_blnc_org.closing_balance += amount
        ledger_blnc_cost_center.opening_balance += amount
        ledger_blnc_cost_center.closing_balance += amount

        ledger_blnc_cost_center.save!
        ledger_blnc_org.save!
      end
    end

  end
end