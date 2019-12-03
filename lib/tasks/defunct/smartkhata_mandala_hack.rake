# This file might not be needed anymore
# no more hacks

# hack to fix data in smartkhata in reference to mandala
namespace :smartkhata_mandala_hack do

  # Steps:
  # clear unwanted data
  # upload customer registration
  # upload mandala data balance
  # upload floorsheet
  # upload payments mandala
  # upload sales
  # generate sales bills

  desc "Hack for the data fixes"
  task :patch_jvr_data, [:tenant] => :environment do |task, args|
    include CustomDateModule
    include ApplicationHelper

    def has_client_ledger(particular_list)
      not_include_codes = ['10301-6900','10301-4252','10301-2349','1030510','4010000000055','4010000000047','4010000000056','4010000000028','401000000006','4010000000035','4010000000057','4010000000033' ,'103020200002','401000000016','103020100007','4010000000059']


      return_status =  false
      particular_list.each do |row|
        # if row['VOUCHER_NO'].strip == '7374-04696'
        # end
        if (not_include_codes.include?(row['AC_CODE'].strip))
          return false
        elsif (row['AC_CODE'].include? '10301')
          return_status =  true
        end
      end
      return return_status
    end

    def is_valid_for_ledger_entry(ledger, particular)
      if ledger.nil?
        puts "no ledger present for #{particular['AC_NAME']}"
        return false
      elsif ( ['DR', 'CR'].include? particular['TRANSACTION_TYPE']) && (particular['NRS_AMOUNT'].to_f > 0)
        return true
      end
      return false
    end

    if args.tenant.present?
      tenant = args.tenant
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      UserSession.selected_fy_code= 7374
      UserSession.selected_branch_id = 1

      puts "uploading jv"
      filename = Rails.root.join('test_files', 'smartkhata_data_upload', args.tenant,'voucher_jvr.csv')

      count = 0


      arr = {
           '1030201000011' => "Bank:Global IME Bank(7501010000706)",
           '1030509' =>  "Close Out",
           '204010000001' => "Nepse Purchase",
           '10301-01' =>  "Nepse Sales",
           '103020200001' => "Cash" ,
           '303001' => "DP Fee/ Transfer",
           '20406' => "TDS",
           '10301-02' => "NAME TRANSFER FEE",
           '10301-4402' => "RIDDHI SIDDHI MULTI-PURPOSE CO-OPERATIVE LTD.",

      }

      client_arr = {
          "10301-4708"=>"BHIM", "10301-7175"=>"BH034514", "10301-5497"=>"S1185", "10301-748"=>"B145", "10301-4355"=>"N758", "10301-2941"=>"MT238684", "10301-7180"=>"KT032232", "10301-7181"=>"SM032256", "10301-7179"=>"TG032260", "10301-5563"=>"NMT23", "10301-3281"=>"KT177608", "10301-752"=>"SS193103", "10301-1749"=>"US193101", "10301-6769"=>"LT165623", "10301-1808"=>"A142", "10301-1800"=>"A143", "10301-8192"=>"JD268745", "10301-2944"=>"KP238673",
          "10301-5005" => 'BROKER_SEC_46', '10301-6324'=> 'BROKER_SEC_43'
      }



      vouchers = Hash.new

      CSV.foreach(filename, :headers => true) do |row|
        unless vouchers.keys.include? row['VOUCHER_NO']
          vouchers[row['VOUCHER_NO']] = []
        end
        vouchers[row['VOUCHER_NO']] << row
      end


      client_vouchers = vouchers.select{|x,y| has_client_ledger(y) }
      non_client_vouchers = vouchers.select{|x,y| !has_client_ledger(y)}

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

      CSV.open("voucher_pending.csv", 'w') do |writer|
        header = %w(VOUCHER_DATE VOUCHER_NO	VOUCHER_CODE	AC_CODE	SUB_CODE	PARTICULARS	CURRENCY_CODE	AMOUNT	CONVERSION_RATE	NRS_AMOUNT	TRANSACTION_TYPE	COST_REVENUE_CODE	INVOICE_NO	VOU_PERIOD	AGAINST_AC_CODE	AGAINST_SUB_CODE	CHEQUE_NO	SERIAL_NO	FISCAL_YEAR	AC_NAME	NEPSE_CUSTOMER_CODE)
        writer << header
        writer << ['*********']
        non_client_vouchers.each do |voucher, particulars|
          particulars.each do |row|
            writer << row
          end
          writer << ['*********']
        end
      end

      ActiveRecord::Base.transaction do
        client_vouchers.each do |voucher, particulars|

          # create a jvr
          description = particulars.first['PARTICULARS']
          voucher_date = Date.parse(particulars.first['VOUCHER_DATE'])

          if description.blank? || voucher_date.blank?
            raise ActiveRecord::Rollback
            break
          end

          client_branch_id = 1

          voucher = Voucher.create!(date: voucher_date, date_bs: ad_to_bs_string(voucher_date))
          voucher.desc = description
          voucher.complete!
          voucher.save!

          particulars.each do |row|
            client_account = ClientAccount.find_by(ac_code: row["AC_CODE"].to_i)
            client_account ||= ClientAccount.find_by(nepse_code: row["NEPSE_CUSTOMER_CODE"])
            ledger = nil

            is_debit = row['TRANSACTION_TYPE'] == 'DR' ? true : false
            amount = row['NRS_AMOUNT'].to_f

            if client_account.nil?
              unless arr.keys.include? row['AC_CODE']
                unless client_arr.keys.include? row['AC_CODE']
                  client_accounts = ClientAccount.where('name ilike ?', row['AC_NAME'].strip)
                  if client_accounts.size == 1
                    client_arr[row['AC_CODE']] = client_accounts.first.nepse_code
                    ledger = client_accounts.first.ledger
                  else
                    puts "#{row['AC_NAME']}  #{row['AC_CODE']}"
                  end
                else
                  client_account = ClientAccount.find_by(nepse_code: client_arr[row["AC_CODE"]])
                  ledger = client_account.ledger
                end
              else
                ledger = Ledger.find_by_name(arr[row['AC_CODE']])
              end
            else
              ledger = client_account.ledger
            end

            if ledger.nil?
              puts "no ledger found for #{row['AC_NAME']}"
              raise ActiveRecord::Rollback
              break
            end

            if is_valid_for_ledger_entry(ledger, row)
              process_accounts(ledger, voucher, is_debit, amount, description, client_branch_id, voucher_date)
            else
              raise ActiveRecord::Rollback
              break
            end

          end
        end
      end


      puts "#{vouchers.size} vouchers need to be inserted"
      puts "#{client_vouchers.size} cleint vouchers need to be inserted"
      puts "#{non_client_vouchers.size} non client vouchers need to be inserted"

      # puts "#{count} clients need your attention"
      Apartment::Tenant.switch!('public')
    else
      puts 'Please pass a tenant to the task'
    end
  end

  task :match_cheque_data_in_csv => :environment do

    mandala = Hash.new
    mandala_name_column =  1
    mandala_cheque_number_column = 2
    CSV.foreach('mandala.csv', :headers => false) do |row|
      # puts "#{row[mandala_cheque_number_column]} , #{row[mandala_name_column]}"
      unless mandala.keys.include? row[mandala_name_column]
        mandala[row[mandala_name_column]] = row
      else
        "**redundant/duplicate #{row[mandala_cheque_number_column]}"
      end
    end

    smartkhata = Hash.new
    smartkhata_name_column =  1
    smartkhata_cheque_number_column = 2
    CSV.foreach('smartkhata.csv', :headers => false) do |row|
      if mandala.keys.include? row[smartkhata_name_column]
        new_cheque = mandala[row[smartkhata_name_column]][mandala_cheque_number_column]
        row << new_cheque
        smartkhata[row[smartkhata_name_column]] = row
        puts row
      else
        "**redundant/duplicate #{row[smartkhata_name_column]}"
      end
    end

    CSV.open("cheque_new.csv", 'w') do |writer|
      smartkhata.each do |voucher, row|
        writer << row
      end
    end
  end

  task :match_cheque_data_in_db , [:tenant] => :environment do |task, args|
    if args.tenant.present?
      tenant = args.tenant
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      UserSession.selected_fy_code= 7374
      UserSession.selected_branch_id = 1

      counta = 0
      countb = 0
      cheque_number_column_x =  4
      cheque_number_column_y =  8
      mandala = Hash.new
      CSV.foreach('cheque_new.csv', :headers => false) do |row|
        if  row[cheque_number_column_x] != row[cheque_number_column_y]
          unless mandala.keys.include? row[cheque_number_column_x]
            mandala[row[cheque_number_column_x]] = row[cheque_number_column_y]
          else
            "redundant #{row[cheque_number_column_x]}"
          end
        end

      end
      puts mandala

      new_dummy_cheque = Hash.new
      new_dummy_placeholder = 1010100

      ActiveRecord::Base.transaction do

        mandala.each do |old,new|
          cheque_number = new_dummy_cheque[old] || old
          c = ChequeEntry.find_by_cheque_number(cheque_number)
          n = ChequeEntry.find_by_cheque_number(new)

          new_dummy_placeholder += 1
          if n.present?
            new_dummy_cheque[new] = new_dummy_placeholder
            n.cheque_number = new_dummy_placeholder
            n.save!
          end

          c.cheque_number = new
          c.save!
        end
      end

      puts mandala.size

    else
      puts "invalid"
    end
  end

  desc "Used to change the date of settlements to match the cheque entry dates"
  task :match_settlement_date_with_cheque_entry_date_in_db, [:tenant] => :environment do |task, args|
    extend CustomDateModule
    # Get array of cheque_entries whose associated settlements' dates are to be changed.
    # Get array of associated settlements
    # Loop through the settlement, and change the date to match that of cheque_entry
    if args.tenant.present?
      tenant = args.tenant
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      UserSession.selected_fy_code= 7374
      UserSession.selected_branch_id = 1

      cheque_number_column = 0
      count = 0
      cheque_entry_numbers = []
      CSV.foreach('match_settlement_date_with_cheque_entry_date.csv', :headers => false) do |row|
        cheque_entry_numbers << row[cheque_number_column]
        count += 1
      end
      mismatched_date_count = 0
      settlement_not_found_count = 0
      ActiveRecord::Base.transaction do
        cheque_entry_numbers.each do |cheque_number|
          cheque_entry = ChequeEntry.find_by_cheque_number(cheque_number)
          voucher_id = cheque_entry.particulars.first.voucher_id
          settlement = Settlement.where(voucher_id: voucher_id, client_account_id: cheque_entry.client_account_id).first
          if settlement.present?
            if settlement.date != cheque_entry.cheque_date
              puts "Date mismatch between settlement with id: #{settlement.id} dated #{settlement.date_bs} and cheque_entry with id: #{cheque_entry.id} dated #{ad_to_bs(cheque_entry.cheque_date)}"
              puts " Matching..."
              puts
              cheque_entry_cheque_date_bs = ad_to_bs(cheque_entry.cheque_date)
              settlement.date_bs = cheque_entry_cheque_date_bs
              settlement.save!
              mismatched_date_count += 1
            end
          else
            settlement_not_found_count += 1
            p "Settlement for cheque_entry with id #{cheque_entry.id} NOT FOUND"
          end
        end
        puts
        puts "SUMMARY:"
        puts " Total records processed: #{cheque_entry_numbers.count}"
        puts " Total mismatched records corrected: #{mismatched_date_count}"
        puts " Total settlements NOT FOUND for given cheque_entries: #{settlement_not_found_count}"
        puts " Please view the log above for more."
      end
    else
      puts "Invalid argument!"
    end
  end

  desc "Hack for payment receipt voucer"
  task :patch_pay_rcv_data, [:tenant] => :environment do |task, args|
    include CustomDateModule
    include ApplicationHelper

    def has_specific_missing_ledger(particular_list)
      not_include_codes = ['10301-4402','20419', '20422', '103020100001', '201000000009', '10301-6132', '10301-5103', '10301-7073', '10301-1802', '10301-7716','10301-966']
      return_status =  false
      particular_list.each do |row|
        if (not_include_codes.include?(row['AC_CODE'].strip))
          return true
        end
      end
      return return_status
    end

    def is_valid_for_ledger_entry(ledger, particular)
      if ledger.nil?
        puts "no ledger present for #{particular['AC_NAME']}"
        return false
      elsif ( ['DR', 'CR'].include? particular['TRANSACTION_TYPE']) && (particular['NRS_AMOUNT'].to_f > 0)
        return true
      end
      return false
    end

    if args.tenant.present?
      tenant = args.tenant
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      UserSession.selected_fy_code= 7374
      UserSession.selected_branch_id = 1

      puts "uploading pvr rcv"
      filename = Rails.root.join('test_files', 'smartkhata_data_upload', args.tenant,'voucher_pv_rcv_filtered.csv')

      count = 0


      arr = {
          '1030201000011' => "Bank:Global IME Bank(7501010000706)",
          '1030509' =>  "Close Out",
          '204010000001' => "Nepse Purchase",
          '10301-01' =>  "Nepse Sales",
          '103020200001' => "Cash" ,
          '303001' => "DP Fee/ Transfer",
          '20406' => "TDS"
      }

      # client_arr = {
      #     "10301-4708"=>"BHIM", "10301-7175"=>"BH034514", "10301-5497"=>"S1185", "10301-748"=>"B145", "10301-4355"=>"N758", "10301-2941"=>"MT238684", "10301-7180"=>"KT032232", "10301-7181"=>"SM032256", "10301-7179"=>"TG032260", "10301-5563"=>"NMT23", "10301-3281"=>"KT177608", "10301-752"=>"SS193103", "10301-1749"=>"US193101", "10301-6769"=>"LT165623", "10301-1808"=>"A142", "10301-1800"=>"A143", "10301-8192"=>"JD268745", "10301-2944"=>"KP238673",
      #     "10301-5005" => 'BROKER_SEC_46', '10301-6324'=> 'BROKER_SEC_43'
      # }

      client_arr = {"10301-6968"=>"BB030919", "10301-4871"=>"SUN13", "10301-4872"=>"SUN12", "10301-2339"=>"NB1", "10301-4495"=>"S1894", "10301-3502"=>"L889", "10301-3537"=>"R879", "10301-409"=>"B93", "10301-3511"=>"M890", "10301-4227"=>"R976", "10301-3505"=>"M824", "10301-4101"=>"S749", "10301-3510"=>"S690", "10301-4365"=>"G1042", "10301-4184"=>"RS264043", "10301-4547"=>"M1072", "10301-3416"=>"R789", "10301-4600"=>"S1774", "10301-1811"=>"T94", "10301-1541"=>"G88", "10301-1542"=>"S395", "10301-1544"=>"G86", "10301-990"=>"I30", "10301-7302"=>"B155", "10301-962"=>"G66", "10301-1795"=>"U29", "10301-1801"=>"M186", "10301-1805"=>"T96", "10301-1806"=>"D185", "10301-1807"=>"Y39", "10301-1810"=>"T95", "10301-2926"=>"NPP22", "10301-6605"=>"SM015468", "10301-6168"=>"RP12", "10301-7795"=>"MSP21", "10301-6836"=>"DK019043", "10301-1889"=>"B322", "10301-974"=>"P178", "10301-1804"=>"G107","10301-5005" => 'BROKER_SEC_46', '10301-6324'=> 'BROKER_SEC_43'}


      vouchers = Hash.new
      CSV.foreach(filename, :headers => true) do |row|
        unless vouchers.keys.include? "#{row['VOUCHER_NO']}-#{row['VOUCHER_CODE']}"
          vouchers["#{row['VOUCHER_NO']}-#{row['VOUCHER_CODE']}"] = []
        end
        vouchers["#{row['VOUCHER_NO']}-#{row['VOUCHER_CODE']}"] << row
      end

      importable_vouchers = vouchers.select{|x,y| !has_specific_missing_ledger(y)}
      missing_ledger_vouchers = vouchers.select{|x,y| has_specific_missing_ledger(y)}



      CSV.open("payment_voucher_pending.csv", 'w') do |writer|
        header = %w(VOUCHER_DATE VOUCHER_NO	VOUCHER_CODE	AC_CODE	SUB_CODE	PARTICULARS	CURRENCY_CODE	AMOUNT	CONVERSION_RATE	NRS_AMOUNT	TRANSACTION_TYPE	COST_REVENUE_CODE	INVOICE_NO	VOU_PERIOD	AGAINST_AC_CODE	AGAINST_SUB_CODE	CHEQUE_NO	SERIAL_NO	FISCAL_YEAR	AC_NAME	NEPSE_CUSTOMER_CODE)
        writer << header
        writer << ['*********']
        missing_ledger_vouchers.each do |voucher, particulars|
          particulars.each do |row|
            writer << row
          end
          writer << ['*********']
        end
      end

      ActiveRecord::Base.transaction do
        importable_vouchers.each do |vchr, particulars|

          # create a jvr
          description = particulars.first['PARTICULARS']
          voucher_date = Date.parse(particulars.first['VOUCHER_DATE'])

          bank_account= BankAccount.by_branch_id.first
          cash_ledger = Ledger.find_or_create_by!(name: "Cash")
          bank_ledger = bank_account.ledger


          if description.blank? || voucher_date.blank?
            raise ActiveRecord::Rollback
            break
          end

          client_branch_id = 1

          # voucher = Voucher.create!(date: voucher_date, date_bs: ad_to_bs_string(voucher_date))
          # voucher.desc = description
          # voucher.complete!
          # voucher.save!

          is_cash = false
          if vchr.include? '-PVB'
            voucher = Voucher.create!(date: voucher_date, date_bs: ad_to_bs_string(voucher_date), voucher_type: Voucher.voucher_types[:payment])
          elsif vchr.include? '-RCB'
            voucher = Voucher.create!(date: voucher_date, date_bs: ad_to_bs_string(voucher_date), voucher_type: Voucher.voucher_types[:receipt])
          else
            voucher = Voucher.create!(date: voucher_date, date_bs: ad_to_bs_string(voucher_date), voucher_type: Voucher.voucher_types[:receipt])
            is_cash = true
          end
          voucher.complete!


          particulars.each do |row|
            puts "uploading data for #{row['AC_NAME']}..."
            client_account = ClientAccount.find_by(ac_code: row["AC_CODE"].to_i)
            client_account ||= ClientAccount.find_by(nepse_code: row["NEPSE_CUSTOMER_CODE"])
            ledger = nil

            description = row['PARTICULARS']
            description += "( by cheque: #{row['CHEQUE_NO']})" if row['CHEQUE_NO'].present?

            is_debit = row['TRANSACTION_TYPE'] == 'DR' ? true : false
            amount = row['NRS_AMOUNT'].to_f

            if client_account.nil?
              unless arr.keys.include? row['AC_CODE']
                unless client_arr.keys.include? row['AC_CODE']
                  client_accounts = ClientAccount.where('name ilike ?', row['AC_NAME'].strip)
                  if client_accounts.size == 1
                    client_arr[row['AC_CODE']] = client_accounts.first.nepse_code
                    ledger = client_accounts.first.ledger
                  else
                    puts "#{row['AC_NAME']}  #{row['AC_CODE']}"
                  end
                else
                  client_account = ClientAccount.find_by(nepse_code: client_arr[row["AC_CODE"]])
                  ledger = client_account.ledger
                end
              else
                ledger = Ledger.find_by_name(arr[row['AC_CODE']])
              end
            else
              ledger = client_account.ledger
            end


            # if ledger.nil?
            #   puts "no ledger found for #{row['AC_NAME']}"
            #   raise ActiveRecord::Rollback
            #   break
            # end

            if is_valid_for_ledger_entry(ledger, row)
              process_accounts(ledger, voucher, is_debit, amount, description, client_branch_id, voucher_date)
              if is_cash
                process_accounts(cash_ledger, voucher, !is_debit, amount, description, client_branch_id, voucher_date)
              else
                process_accounts(bank_ledger, voucher, !is_debit, amount, description, client_branch_id, voucher_date)
              end
            else
              raise ActiveRecord::Rollback
              break
            end
          end
        end
      end
      # puts client_arr
      # puts "#{count} clients need your attention"
      Apartment::Tenant.switch!('public')
    else
      puts 'Please pass a tenant to the task'
    end
  end


  desc "Reverse mandala payment receipt"
  task :revert_payment_receipts, [:tenant] => :environment do |task,args|
    if args.tenant.present?
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      UserSession.selected_branch_id = 1
      UserSession.selected_fy_code = 7374

      file = Rails.root.join('test_files', 'smartkhata_data_upload', args.tenant, 'receipt_payment_slip_filtered.csv')

      # puts file

      puts "Reversing payment receipts.."
      #
      file_upload_param = ActionDispatch::Http::UploadedFile.new(
          tempfile: File.new(file),
          filename: file.to_s
      )

      file_upload = SysAdminServices::ImportPaymentsReceipts.new(file_upload_param)

      reverse = args.reverse.present? ? args.reverse : false

      file_upload.process(true)
      file_upload.processed_data
      puts file_upload.error_message
      puts "Task completed " unless file_upload.error_message

      Apartment::Tenant.switch!('public')
    else
      puts 'Please pass a tenant to the task'
    end
  end
end
