namespace :mandala do
  desc "sync bills"
  task :sync_bills,[:tenant] => 'mandala:validate_tenant' do |task,args|

    def time_diff_more?(start_time, end_time, second)
      seconds_diff = (start_time - end_time).to_i.abs
      return true if seconds_diff > second
      false
    end

    count = 0
    bills = []
    # bills = Mandala::Bill.where('bill_date_parsed > ?', Date.parse('2016-7-15') )
    #
    ActiveRecord::Base.transaction do
      Mandala::Bill.where(bill_id: nil, fiscal_year: '2071/2072').find_each do |bill|
      # Mandala::Bill.where('bill_date_parsed > ?', Date.parse('2016-7-15') ).where(bill_id: nil).each do |bill|
        start_time = Time.now
        pending_bill = []
        bills_taking_time = []

        new_bill = bill.new_smartkhata_bill
        if new_bill.has_incorrect_fy_code?
          # puts "#{bill.bill_no}"
        else
          begin
            new_bill.save!
            bill.bill_id= new_bill.id
            bill.save!
            bill.bill_details.each do |bill_detail|
              daily_transaction = bill_detail.daily_transaction
              share_transaction = daily_transaction.new_smartkhata_share_transaction(bill.bill_no)
              share_transaction.bill_id = new_bill.id
              share_transaction.save!
              daily_transaction.share_transaction_id = share_transaction.id
              daily_transaction.save!

            end
              #   share settlements
          rescue NotImplementedError
            puts "#{bill.bill_no} has no share transactions"
          end

        end
        puts "#{bill.bill_no}"
        count += 1
        puts "#{count} bill processed"
      end
    end
    puts "bills synched"
  end

  task :patch_existing_bills, [:tenant] => 'mandala:validate_tenant' do |task, args|
    ActiveRecord::Base.transaction do
      # Bill.where('date > ?', Date.parse('2016-9-14') ).order(date: :asc).find_each do |bill|
      #   bill.bill_number = nil
      #   bill.save!
      # end
      # the mandala voucher were imported before this date
      bill_number = Bill.where('date <=?', Date.parse('2016-9-14') ).order(bill_number: :desc).first.bill_number
      Bill.where('date > ?', Date.parse('2016-9-14') ).order(date: :asc).find_each do |bill|
        bill_number += 1
        bill.bill_number = bill_number
        bill.save!
        puts "#{bill.id}"
          # raise ArgumentError

      end
    end
  end
end
