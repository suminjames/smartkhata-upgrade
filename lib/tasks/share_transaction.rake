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

end
