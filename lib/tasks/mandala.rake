namespace :mandala do
  task :validate_tenant, [:tenant] => :environment  do |task, args|
    abort 'Please pass a tenant name' unless args.tenant.present?
    tenant = args.tenant
    Apartment::Tenant.switch!(args.tenant)
    UserSession.selected_branch_id = 1
    UserSession.selected_fy_code = 7374
    UserSession.user = User.first
  end

  desc "upload mandala data"
  task :upload_data, [:tenant] => :environment do |task, args|
    if args.tenant.present?

      tenant = args.tenant
      Apartment::Tenant.switch!(args.tenant)

      # below are the list of tables in mandala
      mandala_files = [
        "account_balance",
        "agm",
        "bank_parameter",
        "bill",
        "bill_detail",
        'broker_parameter',
        'buy_settlement',
        'calendar_parameter',
        'capital_gain_detail',
        "capital_gain_para",
        "chart_of_account",
        "commission_rate",
        "commission",
        "company_parameter_list",
        "company_parameter",
        "customer_child_info",
        "customer_ledger",
        "customer_registration",
        "customer_registration_detail",
        "daily_certificate",
        "daily_transaction_no",
        "daily_transaction",
        "district_para",
        "fiscal_year_para",
        "ledger",
        "mobile_message",
        "organisation_parameter",
        "payout_upload",
        "receipt_payment_detail",
        "receipt_payment_slip",
        "sector_parameter",
        "share_parameter",
        "share_receipt_detail",
        "supplier_bill_detail",
        "supplier_bill",
        "supplier_ledger",
        "supplier",
        "system_para",
        "tax_para",
        "temp_daily_transaction",
        "temp_name_transfer",
        "voucher_detail",
        "voucher_number_configuration",
        "voucher_particulars",
        "voucher_parameter",
        "voucher_transaction",
        "voucher_user",
        "voucher",
        "zone_para",

      ]

      total_time_for_execution = 0

      ActiveRecord::Base.transaction do
        mandala_files.each do |file_name|
          file = Rails.root.join('test_files', 'mandala', args.tenant, "#{file_name}.csv")
          "Mandala::#{file_name.classify}".constantize.delete_all

          # count = 0
          bench = Benchmark.measure do
            CSV.foreach(file, :headers => true, :header_converters => [:downcase]) do |row|
              # break if count > 100
              # count = count + 1
              # puts "entering data for #{row[0]}"
              "Mandala::#{file_name.classify}".constantize.create!(row.to_hash)
            end
          end
          puts "  #{file_name} --> #{bench}"

          total_time_for_execution += bench.total
        end
      end

      puts "Total time elapsed --> #{ total_time_for_execution}"

    else
      puts 'Please pass a tenant to the task'
    end
  end

  desc "remove the data except for few clients"
  task :setup_test, [:tenant] => :environment do |task, args|
    if args.tenant.present?
      tenant = args.tenant
      Apartment::Tenant.switch!(args.tenant)
      UserSession.selected_branch_id = 1
      UserSession.selected_fy_code = 7374
      UserSession.user = User.first


      # map the system accounts


      # customer_ac_codes = ['10301-6515','10301-3206', '10301-4629']
      customer_ac_codes = ['10301-6515']
      customer_codes = Mandala::CustomerRegistration.where(ac_code: customer_ac_codes).pluck(:customer_code)

      Mandala::Bill.where.not(customer_code: customer_codes).delete_all
      bill_numbers = Mandala::Bill.pluck(:bill_no)
      Mandala::BillDetail.where.not(bill_no: bill_numbers).delete_all
      Mandala::CustomerLedger.where.not(customer_code: customer_ac_codes).delete_all

      Mandala::ReceiptPaymentSlip.where.not(customer_code: customer_ac_codes).delete_all
      Mandala::ReceiptPaymentDetail.where.not(customer_code: customer_ac_codes).delete_all

    #   though we need to segregate using the voucher_type it is not done
      voucher_numbers = Mandala::VoucherDetail.where(ac_code: customer_ac_codes).pluck(:voucher_no)
      Mandala::Voucher.where.not(voucher_no: voucher_numbers).delete_all
      Mandala::VoucherDetail.where.not(voucher_no: voucher_numbers).delete_all
      Mandala::Ledger.where.not(voucher_no: voucher_numbers).delete_all

      buy_transaction_numbers = Mandala::DailyTransaction.where(customer_code: customer_codes).pluck(:transaction_no)
      sell_transaction_numbers = Mandala::DailyTransaction.where(seller_customer_code: customer_codes).pluck(:transaction_no)
      transaction_numbers = buy_transaction_numbers + sell_transaction_numbers
      Mandala::DailyTransaction.where.not(transaction_no: transaction_numbers).delete_all
      Mandala::DailyCertificate.where.not(transaction_no: transaction_numbers).delete_all
      Mandala::TempDailyTransaction.where.not(transaction_no: transaction_numbers).delete_all




    else
      puts 'Please pass a tenant to the task'
    end
  end

  task :setup, [:tenant] => 'mandala:validate_tenant' do |task, args|
    Rake::Task['db:migrate'].invoke

    tenant = args.tenant

    #   clear smartkhata data too
    vouchers = Voucher.where('date <= ?', '2016-09-14').pluck(:id)
    BillVoucherAssociation.where(voucher_id: vouchers).delete_all
    Settlement.where(voucher_id: vouchers).delete_all
    Voucher.where('date <= ?', '2016-09-14').delete_all

    particulars = Particular.where('transaction_date <= ?', '2016-09-14').pluck(:id)
    ChequeEntryParticularAssociation.where(particular_id:  particulars).delete_all
    Particular.where('transaction_date <= ?', '2016-09-14').delete_all

    bills = Bill.where('date <= ?', '2016-09-14').pluck(:id)
    BillVoucherAssociation.where(bill_id: bills).delete_all
    Bill.where('date <= ?', '2016-09-14').delete_all

    Rake::Task["mandala:fix_vouchers"].invoke(tenant)
    Rake::Task["mandala:fix_bills"].invoke(tenant)

    Rake::Task["mandala:parse_voucher_date"].invoke(tenant)
    Rake::Task["mandala:parse_bill_date"].invoke(tenant)

    Rake::Task["mandala:setup_opening_balances"].invoke(tenant)
  end

  task :setup_and_sync,[:tenant] => 'mandala:validate_tenant' do |task,args|
    tenant = args.tenant
    Rake::Task["mandala:setup"].invoke(tenant)
    Rake::Task["mandala:sync_data"].invoke(tenant)
  end

  task :parse_voucher_date,[:tenant] => 'mandala:validate_tenant' do |task, args|
    Mandala::Voucher.all.each do |voucher|
      voucher.voucher_date_parsed = Date.parse(voucher.voucher_date)
      voucher.save!
    end
    puts "Voucher dates parsed successfully"
  end

  task :parse_bill_date,[:tenant] => 'mandala:validate_tenant' do |task, args|
    Mandala::Bill.all.each do |bill|
      bill.bill_date_parsed = Date.parse(bill.bill_date)
      bill.save!
    end
    puts "Bill dates parsed successfully"
  end


  task :map_system_ledgers, [:tenant] => :environment do |task, args|
    if args.tenant.present?
      tenant = args.tenant
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user = User.first

      Mandala::SystemPara.smartkhata_mapped_system_ac.each do |k,v|
        chart_of_accounts = Mandala::ChartOfAccount.where(ac_code: k)
        if chart_of_accounts.size > 1
          puts "something went wrong"
        else
          chart_of_account = chart_of_accounts.first
          chart_of_account.ledger_id = v.to_i
          chart_of_account.save!
        end
      end
    end
  end

  task :fix_vouchers, [:tenant] => :environment do |task, args|
    if args.tenant.present?
      tenant = args.tenant
      Apartment::Tenant.switch!(args.tenant)
      UserSession.selected_branch_id = 1
      UserSession.selected_fy_code = 7374
      UserSession.user = User.first

      Voucher.all.each do |v|
        begin

          v.update_attribute('voucher_number', (v.voucher_number + 10000))

        rescue
          puts "error for voucher: #{v.fy_code}-#{v.voucher_number}"
        end
      end

      Bill.all.each do |b|
        begin
          b.update_attribute('bill_number', b.bill_number + 10000)
        rescue
          puts "error for bill: #{b.bill_number}"
        end
      end
      puts "done"
    end
  end

  task :fix_bills, [:tenant] => 'mandala:validate_tenant' do |task, args|
    Bill.all.each do |b|
      begin
        b.update_attribute('bill_number', b.bill_number + 10000)
      rescue
        puts "error for bill: #{b.bill_number}"
      end
    end
    puts "done"
  end


  desc "import the mandala data"
  task :sync_data, [:tenant] => :environment do |task, args|
    if args.tenant.present?
      tenant = args.tenant
      Apartment::Tenant.switch!(args.tenant)
      UserSession.selected_branch_id = 1
      UserSession.selected_fy_code = 7374
      UserSession.user = User.first


      arr = {

          '1030509' =>  "Close Out",
          '204010000001' => "Nepse Purchase",
          '10301-01' =>  "Nepse Sales",
          '103020200001' => "Cash" ,
          '303001' => "DP Fee/ Transfer",
          '402000000002' => "TDS",
          '301000000002' => "Sales Commission",
          # '' => "Purchase Commission"

      }
      group = Group.find_or_create_by!({name: "Investment",report: Group.reports['Balance'], sub_report: Group.sub_reports['Assets'], for_trial_balance: true})

      mandala_smartkhata_group_arr = {
          '103' => 'Current Assets',
          '101' => 'Fixed Assets',
          '102' => 'Investment',

          '201' => 'Capital',
          '202' => 'Reserve & Surplus',
          '203' => 'Loan',
          '204' => 'Current Liabilities',

          '301' => 'Direct Income',
          '302' => 'Indirect Income',

          '401' => 'Indirect Income',
          '402' => 'Indirect Expense',
          '403' => 'Direct Expense'
      }

      mandala_smartkhata_group_arr.each do |k,v|
        chart_of_acc = Mandala::ChartOfAccount.find_by(ac_code: k)
        if chart_of_acc.present?
          chart_of_acc.group_id = Group.find_by(name: v).id
          chart_of_acc.save!
        end
      end



      arr.each do |k,v|
        chart_of_acc = Mandala::ChartOfAccount.find_by(ac_code: k)
        if chart_of_acc.present?
          ledger = Ledger.find_by_name(v)
          chart_of_acc.ledger_id = ledger.id
          chart_of_acc.save!
        end
      end

      bank_arr = {
          '1030201000011' => "Bank:Global IME Bank(7501010000706)",
      }

      bank_arr.each do |k,v|
        chart_of_acc = Mandala::ChartOfAccount.find_by(ac_code: k)
        if chart_of_acc.present?
          ledger = Ledger.find_by_name(v)
          chart_of_acc.ledger_id = ledger.id
          chart_of_acc.save!
        end
      end


      ActiveRecord::Base.transaction do
        bench = Benchmark.measure do
          Rake::Task["mandala:sync_vouchers"].invoke(tenant)
          Rake::Task["mandala:sync_bills"].invoke(tenant)
          Rake::Task["mandala:populate_closing_balance"].invoke(tenant)
        end
        puts "#{bench}"

      end
    else
      puts 'kya majak hai'
    end
  end


end
