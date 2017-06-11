namespace :mandala_alt do

  task :setup_and_sync,[:tenant] => 'mandala:validate_tenant' do |task,args|
    tenant = args.tenant
    Rake::Task["mandala_alt:setup"].invoke(tenant)
    Rake::Task["mandala_alt:sync_data"].invoke(tenant)
  end

  def delete_mandala_data
    bill_ids = Mandala::Bill.where("bill_date_parsed between '2016-07-16' and '2016-09-14'").pluck(:id)
    # consider the fact that there is no extra bill data for new bills being introduced
    additional_bill_ids = Mandala::Bill.where("bill_date_parsed is null and fiscal_year = '2073/2074'").pluck(:id)
    relevant_bill_ids  = bill_ids + additional_bill_ids

    bill_detail_ids = Mandala::BillDetail.joins('INNER JOIN bill  ON bill.bill_no = bill_detail.bill_no').where(bill: {id: relevant_bill_ids}).pluck(:id).uniq
    Mandala::DailyTransaction.joins('INNER JOIN bill_detail  ON bill_detail.transaction_no = daily_transaction.transaction_no and bill_detail.transaction_type = daily_transaction.transaction_type').where(bill_detail: {id: bill_detail_ids}).delete_all
    Mandala::DailyTransaction.where("fiscal_year = '2073/2074' and share_transaction_id is null").delete_all


    Mandala::BillDetail.where(id: bill_detail_ids).delete_all
    puts "Deleting #{Mandala::Bill.where(id: bill_ids).count} Bills"
    Mandala::Bill.where(id: bill_ids).delete_all
    bill_ids = nil; bill_detail_ids = nil;

    voucher_ids = Mandala::Voucher.where("voucher_date_parsed between '2016-07-16' and '2016-09-14'").pluck(:id)
    # consider the fact that there is no extra bill data for new bills being introduced
    additional_voucher_ids = Mandala::Voucher.where("voucher_date_parsed is null and fiscal_year = '2073/2074'").pluck(:id)
    relevant_voucher_ids = voucher_ids + additional_voucher_ids

    Mandala::VoucherDetail.joins('INNER JOIN voucher  ON voucher_detail.voucher_no = voucher.voucher_no and voucher_detail.voucher_code = voucher.voucher_code').where(voucher: {id: relevant_voucher_ids}).delete_all
    Mandala::Ledger.joins('INNER JOIN voucher  ON ledger.voucher_no = voucher.voucher_no and ledger.voucher_code = voucher.voucher_code').where(voucher: {id: relevant_voucher_ids}).delete_all

    receipt_payment_ids = Mandala::ReceiptPaymentSlip.joins('INNER JOIN voucher  ON receipt_payment_slip.voucher_no = voucher.voucher_no and receipt_payment_slip.voucher_code = voucher.voucher_code').where(voucher: {id: relevant_voucher_ids}).pluck(:id).uniq

    Mandala::ReceiptPaymentDetail.joins('INNER JOIN receipt_payment_slip  ON receipt_payment_slip.fiscal_year = receipt_payment_detail.fiscal_year and receipt_payment_slip.slip_type = receipt_payment_detail.slip_type and receipt_payment_slip.slip_no = receipt_payment_detail.slip_no ').where(receipt_payment_slip: {id: receipt_payment_ids}).delete_all

    Mandala::ReceiptPaymentSlip.where(id: receipt_payment_ids).delete_all
    puts "Deleting #{Mandala::Voucher.where(id: voucher_ids).count} Vouchers"
    Mandala::Voucher.where(id: voucher_ids).delete_all
  end

  desc "upload mandala data"
  task :upload_data, [:tenant] => :environment do |task, args|
    if args.tenant.present?

      tenant = args.tenant
      Apartment::Tenant.switch!(args.tenant)



      # below are the list of tables in mandala
      # first enter the data for bills
      mandala_files = [
        "bill",
        "voucher",
      ]

      total_time_for_execution = 0

      ActiveRecord::Base.transaction do
        mandala_files.each do |file_name|
          file = Rails.root.join('test_files', 'mandala', args.tenant, "#{file_name.upcase}_DATA_TABLE.csv")
          next  if !File.exist?(file)

          # count = 0
          bench = Benchmark.measure do
            CSV.foreach(file, :headers => true, :header_converters => [:downcase]) do |row|
              "Mandala::#{file_name.classify}".constantize.create!(row.to_hash)
            end
          end
          puts "  #{file_name} --> #{bench}"

          total_time_for_execution += bench.total
        end
      end

      # deleted related data
      delete_mandala_data

      # insert related bill and voucher data
      mandala_files = [
          "bill_detail",
          "daily_transaction",
          "ledger",
          "receipt_payment_detail",
          "receipt_payment_slip",
          "voucher_detail",
      ]

      total_time_for_execution = 0

      ActiveRecord::Base.transaction do
        mandala_files.each do |file_name|
          file = Rails.root.join('test_files', 'mandala', args.tenant, "#{file_name.upcase}_DATA_TABLE.csv")
          next  if !File.exist?(file)

          # count = 0
          bench = Benchmark.measure do
            CSV.foreach(file, :headers => true, :header_converters => [:downcase]) do |row|
              "Mandala::#{file_name.classify}".constantize.create!(row.to_hash)
            end
          end
          puts "  #{file_name} --> #{bench}"

          total_time_for_execution += bench.total
        end
      end

      Rake::Task["mandala:parse_voucher_date"].invoke(tenant)
      Rake::Task["mandala:parse_bill_date"].invoke(tenant)

      puts "Total time elapsed --> #{ total_time_for_execution}"

    else
      puts 'Please pass a tenant to the task'
    end
  end

  desc "Clear Unwanted Data"
  task :clear_unwanted_old_data, [:tenant] => 'mandala:validate_tenant' do |task, args|
    tenant = args.tenant

    vouchers = Voucher.where("date between '2016-07-16' and '2016-09-14'").pluck(:id)
    BillVoucherAssociation.where(voucher_id: vouchers).delete_all

    #
    particulars = Particular.where(voucher_id: vouchers).pluck(:id)
    ChequeEntryParticularAssociation.unscoped.where(particular_id:  particulars).delete_all
    ParticularsShareTransaction.unscoped.where(particular_id:  particulars).delete_all
    ParticularSettlementAssociation.unscoped.where(particular_id:  particulars).delete_all
    Particular.where(voucher_id: vouchers).delete_all

    bill_ids = Bill.unscoped.where("date between '2016-07-16' and '2016-09-14'").pluck(:id)
    BillVoucherAssociation.where(bill_id: bill_ids).delete_all

    Settlement.unscoped.where("date between '2016-07-16' and '2016-09-14'").delete_all
    Settlement.unscoped.where(voucher_id: vouchers).delete_all
    ShareTransaction.unscoped.where(bill_id: bill_ids).delete_all

    Voucher.where("date between '2016-07-16' and '2016-09-14'").delete_all
    Bill.unscoped.where("date between '2016-07-16' and '2016-09-14'").where.not(id: BillVoucherAssociation.where(bill_id: bill_ids).pluck(:bill_id)).delete_all
  end

  task :setup, [:tenant] => 'mandala:validate_tenant' do |task, args|
    Rake::Task['db:migrate'].invoke
    tenant = args.tenant
    Rake::Task["mandala_alt:clear_unwanted_old_data"].invoke(tenant)

  end

  desc "import the mandala data"
  task :sync_data, [:tenant] => :environment do |task, args|
    if args.tenant.present?
      tenant = args.tenant
      Apartment::Tenant.switch!(args.tenant)
      UserSession.selected_branch_id = 1
      UserSession.selected_fy_code = 7374
      UserSession.user = User.first

      puts "syncing data in alt mode"
      bench = Benchmark.measure do
        Rake::Task["mandala:sync_vouchers"].invoke(tenant,'2073/2074',true)
        Rake::Task["mandala:sync_bills"].invoke(tenant,'2073/2074',true)

        Rake::Task["ledger:populate_ledger_dailies"].invoke(tenant,'true')
        Rake::Task["ledger:populate_closing_balance"].invoke(tenant,'true')
      end
      puts "#{bench}"

    else
      puts 'kya majak hai'
    end
  end
end
