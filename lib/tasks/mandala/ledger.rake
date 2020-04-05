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

  desc "patch opening balance for some ledgers"
  task :setup_opening_balances_for_selected,[:tenant, :ledger_ids] => 'mandala:validate_tenant' do |task,args|
    tenant = args.tenant
    ledger_ids = args.ledger_ids

    if ledger_ids.size > 0
      ledgers = Ledger.where(id: ledger_ids)
      ledgers.each do |ledger|
        chart_of_accounts = Mandala::ChartOfAccount.where(ledger_id: ledger.id)
        if chart_of_accounts.size != 1
          raise ArgumentError if chart_of_accounts.size > 1
          next
        end
        chart_of_account = chart_of_accounts.first
        account_balances =  chart_of_account.account_balances
        account_balances.each do |balance|
          fy_code = balance.fy_code

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

    # CSV.open("voucher_done.csv", 'w') do |writer|
    #   header = %w(VOUCHER_DATE VOUCHER_NO	VOUCHER_CODE	AC_CODE	SUB_CODE	PARTICULARS	CURRENCY_CODE	AMOUNT	CONVERSION_RATE	NRS_AMOUNT	TRANSACTION_TYPE	COST_REVENUE_CODE	INVOICE_NO	VOU_PERIOD	AGAINST_AC_CODE	AGAINST_SUB_CODE	CHEQUE_NO	SERIAL_NO	FISCAL_YEAR	AC_NAME	NEPSE_CUSTOMER_CODE)
    #   writer << header
    #   writer << ['*********']
    #   client_vouchers.each do |voucher, particulars|
    #     particulars.each do |row|
    #       writer << row
    #     end
    #     writer << ['*********']
    #   end
    # end


    puts "Wrong ledger count: #{count}"
    puts "Correct ledger count: #{correct}"
  end

  desc "fix the ledger for some clients without nepse code"
  task :reassign_ledgers,[:tenant] => 'mandala:validate_tenant' do |task,args|
    tenant = args.tenant

    # normally there should be one ledger for a  chart of account in mandala
    # but due to a bug all the account with no nepse code were assigned to wrong ones.
    mismatched_ledger_ids = Mandala::ChartOfAccount.select(:ledger_id).group(:ledger_id).having('count(ledger_id) > 1').pluck(:ledger_id)

    mismatched_ledgers = Ledger.where(id: mismatched_ledger_ids)

    wrong_chart_of_accounts = Mandala::ChartOfAccount.where(ledger_id: mismatched_ledger_ids)

    ActiveRecord::Base.transaction do

    # first remove all the mismatched references

      wrong_chart_of_accounts.each do |account|
        client_registration = account.client_registration
        client_registration.client_account_id = nil
        client_registration.save!
      end

      wrong_chart_of_accounts.update_all(ledger_id: nil)

      ledger_ids = mismatched_ledger_ids || []

      mismatched_ledgers.each do |ledger|
        ledger.particulars.each do |particular|
          mandala_ledgers = Mandala::Ledger.where(particular_id: particular.id)
          # considering the cases where the particular was from smartkhata
          # having no entry on the mandala when migrated.
          if mandala_ledgers.count > 1
            raise ArgumentError
          end

          ledger_id = mandala_ledgers.first.present? ? mandala_ledgers.first.ledger_id : ledger.id
          puts "#{ledger_id}"

          particular.ledger_id = ledger_id
          particular.save!

          ledger_ids << particular.ledger_id
        end
      end
      ledger_ids = ledger_ids.uniq
      Rake::Task["mandala:setup_opening_balances_for_selected"].invoke(tenant, ledger_ids)
      Rake::Task["ledger:populate_ledger_dailies_selected"].invoke(tenant, ledger_ids)
      Rake::Task["ledger:populate_closing_balance_selected"].invoke(tenant, ledger_ids)

      # puts "#{mismatched_ledger_ids}"
    end
  end
end