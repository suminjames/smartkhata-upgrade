namespace :mandala do
  desc "patch opening balance"
  task :setup_opening_balances,[:tenant] => 'mandala:validate_tenant' do |task,args|
    tenant = args.tenant

    Mandala::AccountBalance.all.each do |balance|
      ledger = balance.chart_of_account.ledger
      fy_code = balance.fy_code
      if ledger
        ledger_blnc_org = LedgerBalance.unscoped.by_fy_code_org(fy_code).find_or_create_by!(ledger_id: ledger.id)
        ledger_blnc_cost_center =  LedgerBalance.unscoped.by_branch_fy_code(UserSession.selected_branch_id,fy_code).find_or_create_by!(ledger_id: ledger.id)

        amount = balance.nrs_balance_amount.to_f

        ledger_blnc_org.opening_balance = amount
        ledger_blnc_org.closing_balance = amount
        ledger_blnc_cost_center.opening_balance = amount
        ledger_blnc_cost_center.closing_balance = amount

        ledger_blnc_cost_center.save!
        ledger_blnc_org.save!
      end
    end

  end

  task :populate_closing_balance,[:tenant] => 'mandala:validate_tenant' do |task, args|
    tenant = args.tenant
    ActiveRecord::Base.transaction do
      Ledger.find_each do |ledger|
        fy_code = 7374
        branch_id = 1

        ledger_blnc_org = LedgerBalance.unscoped.by_fy_code_org(fy_code).find_by(ledger_id: ledger.id)
        ledger_blnc_cost_center =  LedgerBalance.unscoped.by_branch_fy_code(UserSession.selected_branch_id,fy_code).find_by(ledger_id: ledger.id)

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
    end
  end
end