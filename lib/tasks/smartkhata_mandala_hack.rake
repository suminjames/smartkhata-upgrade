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
        #   debugger
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

end
