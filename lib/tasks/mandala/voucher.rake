namespace :mandala do
  desc "synch_vouchers"
  task :sync_vouchers,[:tenant, :fiscal_year] => 'mandala:validate_tenant' do |task,args|

    def time_diff_more?(start_time, end_time, second)
      seconds_diff = (start_time - end_time).to_i.abs
      return true if seconds_diff > second
      false
    end

    # vouchers= Mandala::Voucher.all
    # vouchers = Mandala::Voucher.where('voucher_date_parsed > ?', Date.parse('2016-7-15') )

    pending_voucher = []
    vouchers_taking_time = []
    count = 0
    error_count = 0

    # first build vouchers and add the conditional
    vouchers = Mandala::Voucher.where(voucher_id: nil)
    fiscal_year = args.fiscal_year
    if fiscal_year.present?
      vouchers = vouchers.where('fiscal_year = ?', fiscal_year)
    end


    # Mandala::Voucher.where('voucher_date_parsed > ?', Date.parse('2016-7-15') ).find_each do |voucher|

      # Mandala::Voucher.where('voucher_date_parsed > ?', Date.parse('2016-7-15') ).find_each do |voucher|
      vouchers.find_each do |voucher|
        begin
          ActiveRecord::Base.transaction do
          start_time = Time.now

          new_voucher = voucher.new_smartkhata_voucher

          if new_voucher.has_incorrect_fy_code?
            pending_voucher << voucher
          else
            # skip cheque assign step
            new_voucher.skip_cheque_assign = true
            new_voucher.save!
            voucher.voucher_id = new_voucher.id
            voucher.migration_completed = true

            voucher.save!
            fy_code = new_voucher.fy_code

            dr_particulars = []
            cr_particulars = []

            voucher.ledgers.each do |ledger|
              particular = ledger.new_smartkhata_particular(new_voucher.id, fy_code: fy_code)
              particular.save!

              ledger.particular = particular
              ledger.save!

              dr_particulars << particular if particular.dr?
              cr_particulars << particular if particular.cr?
            end

            # payment receipt case
            if voucher.voucher_code != 'JVR'
              receipt_payments = voucher.receipt_payments

              if receipt_payments.size > 1
                raise NotImplementedError
              end

              settlement = nil
              receipt_payments.each do |rp|
                settlement = rp.new_smartkhata_settlement(new_voucher.id, fy_code)
                settlement.save!

                cheque_entries = []
                multi_detailed_cheque = false

                if new_voucher.payment_bank? || new_voucher.receipt_bank?
                  rp.receipt_payment_details.each do |detail|

                    cheque_entry = detail.find_cheque_entry.first
                    if cheque_entry.present?
                      cheque_entry.amount += detail.amount.to_f
                      multi_detailed_cheque = true
                    else
                      cheque_entry = detail.new_smartkhata_cheque_entry(settlement.date, fy_code )
                    end

                    if cheque_entry.present?
                      cheque_entry.skip_cheque_number_validation = true
                      cheque_entry.save!
  
                      detail.cheque_entry_id = cheque_entry.id
                      detail.save!
                      cheque_entries << cheque_entry unless multi_detailed_cheque
                    end
                  end

                  if new_voucher.payment_bank?
                    cr_particulars.each do |particular|
                      cheque_entries.each do |cheque_entry|
                        particular.cheque_entries_on_payment << cheque_entry if cheque_entry.amount == particular.amount
                      end
                    end
                    dr_particulars.each do |particular|
                      if particular.cheque_entries_on_payment.size <= 0
                        particular.cheque_entries_on_payment << cheque_entries
                        particular.save!
                      end
                    end
                  elsif new_voucher.receipt_bank?
                    dr_particulars.each do |particular|
                      cheque_entries.each do |cheque_entry|
                        particular.cheque_entries_on_receipt << cheque_entry if cheque_entry.amount == particular.amount
                      end
                    end

                    cr_particulars.each do |particular|
                      if particular.cheque_entries_on_receipt.size <= 0
                        particular.cheque_entries_on_receipt << cheque_entries
                        particular.save!
                      end
                    end
                  end
                end
              end




              new_voucher.particulars.select{|x| x.dr?}.each do |p|
                p.debit_settlements << settlement if settlement.present?
              end
              new_voucher.particulars.select{|x| x.cr?}.each do |p|
                p.credit_settlements << settlement if settlement.present?
              end


            end

            puts "#{voucher.voucher_no} ** #{voucher.voucher_code}"
            count += 1
            puts "Total processed: #{count}"

            end_time = Time.now
            vouchers_taking_time << voucher if time_diff_more?(start_time, end_time, 5)
          end
          end
        rescue => error
          puts error.message
          puts "#{voucher.voucher_no} ** #{voucher.voucher_code}"
        end
    end



    puts "vouchers synched"
    puts "#{error_count} vouchers have error"
    vouchers_taking_time.each do |voucher|
      puts "#{voucher.voucher_no} ** #{voucher.voucher_code}"
    end

    puts "pending ones"
    pending_voucher.each do |voucher|
      puts "#{voucher.voucher_no} ** #{voucher.voucher_code}"
    end
  end

  task :patch_existing_vouchers, [:tenant] => 'mandala:validate_tenant' do |task, args|
    fy_code = 7374
    branch_id = 1
    ActiveRecord::Base.transaction do
      # first make the voucher number nil
      Voucher.where('date > ?', Date.parse('2016-9-14') ).order(date: :asc).find_each do |voucher|
        voucher.skip_number_assign = true
        voucher.skip_cheque_assign = true

        voucher.voucher_number = nil
        voucher.save!


      end

      # the mandala voucher were imported before this date
      Voucher.where('date > ?', Date.parse('2016-9-14') ).order(date: :asc).find_each do |voucher|
        voucher.map_payment_receipt_to_new_types
        # voucher.voucher_number = nil
        voucher.skip_cheque_assign = true

        voucher.save!
        puts "#{voucher.id}"
          # raise ArgumentError
      end
    end

  end

end
