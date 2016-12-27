namespace :mandala do
  desc "Update missing share transactions, which occurred while running mandala data migration to SmartKhata."
  # Missing share transactions(and their corresponding bills) can occur for days whose payout report haven't been
  # uploaded. For instance. If the migration occured for data taken Friday evening, share transactions(and their
  # corresponding bills) for days Wednesday and Thursday will not be accounted for during the migration.
  task :create_missing_mandala_sales_share_transactions, [:tenant, :date_from, :date_to] => :environment do |task, args|
    include CustomDateModule
    include CommissionModule
    include ShareInventoryModule
    include ApplicationHelper

    if args.tenant != 'dipshikha'
      fail "Invalid tenant! This migration can apparently only be run in dipskhika tenant as of now. Proper testing is required before running this task."
    end

    if args.tenant.blank? || args.date_from.blank?  || args.date_to.blank?
      fail "Invalid Params!"
    end

    date_from_str = args.date_from
    date_to_str = args.date_to

    if !parsable_date?(date_from_str) || !parsable_date?(date_to_str)
      fail "Invalid Date(s)!"
    end

    tenant = args.tenant
    Apartment::Tenant.switch!(tenant)
    UserSession.set_console(tenant)
    date_ad_from = Date.parse(date_from_str)
    date_ad_to = Date.parse(date_to_str)
    dates_arr = []
    (date_ad_from..date_ad_to).each do |date|
      # Change date format to match the date format used by mandala.
      # Mandala uses string in format DD-MMM-YY (14-DEC-16) for dates.
      dates_arr << date.strftime('%d-%b-%y').upcase
    end
    # relevant mandala daily transactions (share transactions)
    daily_transactions =  Mandala::DailyTransaction.where(:transaction_date => dates_arr, :transaction_type => 'S')

    new_share_transaction_counter = 0
    skipped_share_transaction_counter = 0
    puts
    puts "Creating missing sales share transactions, which occurred while running mandala data migration to SmartKhata..."
    ActiveRecord::Base.transaction do
      daily_transactions.each_with_index do |daily_transaction, index|
        # Associated bill
        associated_bill = Mandala::Bill.find_by_bill_no(daily_transaction.seller_bill_no)
        if associated_bill.present?
          puts "Skipping creation of sales share transaction! Also, bill #{associated_bill.try(:bill_no)} already exists for transaction number #{daily_transaction.transaction_no}."
          skipped_share_transaction_counter += 1
        else
          if ShareTransaction.selling.find_by_contract_no(daily_transaction.transaction_no).present?
            puts "Sales share transaction with transaction no #{daily_transaction.transaction_no} already exists."
            skipped_share_transaction_counter += 1
          else
            sk_share_transaction = daily_transaction.new_smartkhata_share_transaction_with_out_bill
            puts "Sales share transaction with transaction no #{daily_transaction.transaction_no} created."
            sk_share_transaction.save!
            new_share_transaction_counter += 1
          end
        end
      end
    end
    puts "Total number of new smartkhata sales share transactions created = #{new_share_transaction_counter}."
    puts "Total number of skipped mandala sales share transactions = #{skipped_share_transaction_counter}."
    puts

    Apartment::Tenant.switch!('public')
  end

end
