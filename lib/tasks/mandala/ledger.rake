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


  desc "verify mandala balance with smartkhata"
  task :verify_balances,[:tenant] => 'mandala:validate_tenant' do |task,args|
    tenant = args.tenant

    file = Rails.root.join('test_files', 'mandala', args.tenant, "trial_balance.csv")
    count = 0
    correct = 0
    #<CSV::Row "ac code":"10301-01" "ac name":"NEPSE SALES" "opening dr.":"1789927.89" "opening cr.":nil "dr. amount":"2122400933.86" "cr. amount":"1591514476.29" "balance dr.":"532676385.46" "balance cr.":nil>
    CSV.foreach(file, :headers => true, :header_converters => [:downcase]) do |row|
      ac_code = row['ac code']
      ac_name = row['ac name']
      balance_dr = row['balance dr.'].to_f
      balance_cr = row['balance cr.'].to_f

      ledger = Mandala::ChartOfAccount.where(ac_code: ac_code).first.try(:ledger)
      if ledger.present?
        closing_balance = ledger.closing_balance.to_f
        mandala_closing_balance =  closing_balance >=  0 ? balance_dr : (balance_cr * -1)
        if (mandala_closing_balance - closing_balance).abs >= 100
          count += 1
          puts "#{ac_code} #{ac_name} mandala-balance: #{mandala_closing_balance} smartkhata-closing_balance: #{closing_balance}"
        else
          correct += 1
        end
      else
        # puts ac_name
      end
    end

    CSV.open("voucher_done.csv", 'w') do |writer|
      header = %w(VOUCHER_DATE VOUCHER_NO	VOUCHER_CODE	AC_CODE	SUB_CODE	PARTICULARS	CURRENCY_CODE	AMOUNT	CONVERSION_RATE	NRS_AMOUNT	TRANSACTION_TYPE	COST_REVENUE_CODE	INVOICE_NO	VOU_PERIOD	AGAINST_AC_CODE	AGAINST_SUB_CODE	CHEQUE_NO	SERIAL_NO	FISCAL_YEAR	AC_NAME	NEPSE_CUSTOMER_CODE)
      writer << header
      writer << ['*********']
      client_vouchers.each do |voucher, particulars|
        particulars.each do |row|
          writer << row
        end
        writer << ['*********']
      end
    end


    puts "Wrong ledger count: #{count}"
    puts "Correct ledger count: #{correct}"
  end
end