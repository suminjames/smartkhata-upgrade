namespace :share_transaction do
  # fix the transaction type
  desc "fix missing transaction_type"
  task :fix_transaction_type,[:tenant] => 'smartkhata:validate_tenant' do |task, args|
    Mandala::DailyTransaction.find_each do |x|
      x.share_transaction.update(transaction_type: x.sk_transaction_type) if x.share_transaction_id.present?
    end
    puts "updated share transactions"

    #patch the transaction type u
  end


  # duplicate share transactions
  # while migrating from the mandala there has been duplicates
  # delete the transactions and map their bill to the other share transaction
  desc "patch duplicate share transactions"
  task :merge_duplicates,[:tenant] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant

  #   check if there are missing transaction_type
    wrong_share_transaction_count = ShareTransaction.where(transaction_type: nil).count
    ActiveRecord::Base.transaction do
      if wrong_share_transaction_count <= 0
        Rake::Task["share_transaction:fix_transaction_type"].invoke(tenant)
      else

      end
    end

  end

#   patch wrong sales exceeding 5000000
  desc "patch large value sales"
  task :patch_large_sales,[:tenant] => 'smartkhata:validate_tenant' do |task, args|

    include CommissionModule
    include CustomDateModule
    include FiscalYearModule

    tds_rate = 0.15
    tenant = args.tenant

    # share transactions of type selling with amount greater than 5000000 are outside settlement and need processing
    share_transactions = ShareTransaction.where("date >= '2016-09-14'").where(transaction_type: 1).where('share_amount > 5000000')

    ActiveRecord::Base.transaction do
      ledgers = []
      nepse_ledger = Ledger.find_by(name: "Nepse Sales")

      share_transactions.each do |transaction|

        # calculations to fix wrong values
        chargeable_by_nepse = nepse_commission_rate(transaction.date) + broker_commission_rate(transaction.date) * tds_rate
        chargeable_on_sale_rate = broker_commission_rate(transaction.date) * (1 - tds_rate)
        amount_receivable = transaction.share_amount - ( transaction.sebo + transaction.commission_amount * chargeable_by_nepse + transaction.cgt )
        net_amount = amount_receivable - (transaction.commission_amount * chargeable_on_sale_rate) - transaction.dp_fee

        # process only if the amount receivable is wrong
        # in case of transactions with cgt the buggy code used to work
        if (transaction.amount_receivable - amount_receivable ).abs > 0.01

          puts "error for share transaction #{transaction.contract_no}"
          puts "#{transaction.client_account.name} date: #{ad_to_bs(transaction.date)} ledger_id: #{transaction.client_account.ledger.id}"
          puts "for client #{net_amount}  for nepse sales #{ amount_receivable}"

          # first fix bills
          bill = transaction.bill

          # bill is present when the transaction is processed
          if bill.present? && (transaction.net_amount - net_amount).abs > 0.01
            puts "bill net amount #{ bill.net_amount} actual amount: #{ bill.net_amount - transaction.net_amount + net_amount }"
            bill.net_amount = bill.net_amount - transaction.net_amount + net_amount
            bill.save!

            ledger_id = transaction.client_account.ledger.id
            ledgers << ledger_id

            # fix the particulars
            date_for_fy = transaction.settlement_date || Calendar::t_plus_3_working_days(transaction.date)
            fy_code = get_fy_code(date_for_fy)

            # make sure the particular is single
            particulars = Particular.unscoped.where(fy_code: fy_code, ledger_id: ledger_id, amount: transaction.net_amount, particular_status: 1)
            if particulars.size != 1
              raise NotImplementedError
            end
            particular = particulars.first

            # same case for nepse sales
            nepse_sales_particulars = Particular.unscoped.where(fy_code: fy_code, ledger_id: nepse_ledger.id, voucher_id: particular.voucher_id)
            if nepse_sales_particulars.size != 1
              raise NotImplementedError
            end
            nepse_sales_particular = nepse_sales_particulars.first

            puts "nepse sales earlier value: #{nepse_sales_particular.amount} "
            particular.amount = net_amount
            nepse_sales_particular.amount = amount_receivable
            particular.save!
            nepse_sales_particular.save!
          end

          # fix transaction
          transaction.amount_receivable = amount_receivable
          transaction.net_amount = net_amount
          transaction.save!
        end
      end

      #   fix the ledgers
      if ledgers.size > 0
        ledgers << nepse_ledger
        ledgers = ledgers.uniq.join(" ")
        Rake::Task["ledger:populate_ledger_dailies_selected"].invoke(tenant, ledgers)
        Rake::Task["ledger:populate_closing_balance_selected"].invoke(tenant, ledgers)
      end

    end


  end

  task :update_share_transaction_branch,[:tenant, :branch_id, :dry_run, :date, :client_account_id] => 'smartkhata:validate_tenant' do |task, args|

    include FiscalYearModule

    if args.client_account_id === 'nil'
      client_accounts = ClientAccount.where(branch_id: args.branch_id).pluck(:id)
    else
      client_accounts = [args.client_account_id]
    end
    if args.date === 'nil'
      from_date = fiscal_year_first_day
    else
      from_date = args.date
    end
    # from_date = args.date || fiscal_year_first_day
    share_transactions = ShareTransaction.unscoped.where('date >=?', from_date).where(client_account_id: client_accounts).where.not(branch_id: args.branch_id)
    if args.dry_run === 'false'
      share_transactions.update_all(branch_id: args.branch_id)
    else
      puts "Sharetransactions affected: #{share_transactions.count}"
    end
  end


  task :fix_commission_change_fix,[:tenant, :date] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    date = args.date

    purchase_commission_ledger = Ledger.find_by(name: "Purchase Commission")
    sales_commission_ledger = Ledger.find_by(name: "Sales Commission")
    nepse_ledger = Ledger.find_by(name: "Nepse Purchase")
    nepse_sales = Ledger.find_by(name: "Nepse Sales")
    tds_ledger = Ledger.find_by(name: "TDS")
    dp_ledger = Ledger.find_by(name: "DP Fee/ Transfer")
    compliance_ledger = Ledger.find_by(name:  "Compliance Fee")

    default_ledgers = [purchase_commission_ledger.id, nepse_ledger.id, tds_ledger.id, dp_ledger.id, sales_commission_ledger.id, nepse_sales.id]
    share_transactions = ShareTransaction.where('date >= ?', date).where(commission_rate: 'flat_25')

    puts share_transactions.to_sql
    puts "total: #{share_transactions.count}"

    particulars =  Particular.where(voucher_id: share_transactions.select(:voucher_id)).where.not(ledger_id: default_ledgers)

    particulars.cr.update_all("amount = amount + 10.2")
    particulars.dr.update_all("amount = amount - 15")

    value_dates =  particulars.pluck(:value_date).uniq
    transaction_dates =  particulars.pluck(:transaction_date).uniq
    ledgers = particulars.pluck(:ledger_id)

    Particular.where(voucher_id: share_transactions.select(:voucher_id), ledger_id: tds_ledger.id).update_all(amount: 1.2)
    Particular.where(voucher_id: share_transactions.select(:voucher_id), ledger_id: [nepse_ledger.id]).update_all('amount = amount - 4.8 ')
    Particular.where(voucher_id: share_transactions.select(:voucher_id), ledger_id: [purchase_commission_ledger.id, sales_commission_ledger.id]).update_all(amount: 8)

    share_transactions.find_each do |st|
      bill = st.bill
      if bill.present?
        amount = bill.sales? ? -10.2 : 15
        bill.update(net_amount: bill.net_amount - amount, balance_to_pay: bill.balance_to_pay - amount )
      end
    end

    share_transactions.buying.update_all("commission_rate = 'flat_10', net_amount = net_amount + 15, commission_amount = 10, nepse_commission = 2")
    share_transactions.selling.where(bill_id: nil).update_all("commission_rate = 'flat_10', commission_amount = 10, nepse_commission = 2")
    share_transactions.selling.where.not(bill_id: nil).update_all("commission_rate = 'flat_10', net_amount = net_amount + 10.2, commission_amount = 10, nepse_commission = 2")

    ledger_ids = ledgers + default_ledgers

    Branch.pluck(:id).each do |branch_id|
      unless ledger_ids.blank?
        fy_code = current_fy_code
        ActiveRecord::Base.transaction do
          Ledger.where(id: ledger_ids).find_each do |ledger|
            Accounts::Ledgers::PopulateLedgerDailiesService.new.patch_ledger_dailies(ledger, false, current_user_id, branch_id, fy_code, transaction_dates )
            Accounts::Ledgers::ClosingBalanceService.new.patch_closing_balance(ledger, all_fiscal_years: false, branch_id: branch_id, fy_code: fy_code, current_user_id: current_user_id)
          end
        end
      end
    end

    value_dates.each do |value_date|
      if (value_date < Time.current.to_date )
        ledgers.each do |ledger_id|
          InterestJob.perform_later(ledger_id, value_date.to_s)
        end
      end
    end
  end


  task :fix_commission, [:tenant, :transaction_ids] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    transaction_ids = args.transaction_ids.split(" ")
    Fixes::ShareTransactionV2.call(transaction_ids, tenant)
  end
end
