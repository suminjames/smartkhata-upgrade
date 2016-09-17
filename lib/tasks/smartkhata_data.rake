# This is purely hack to kickstart the smartkhata from given floorsheet files
# not to be confused with general purpose
# less time was dedicated for this task and will require code changes for reusability.

namespace :smartkhata_data do

  # Steps:
  # clear unwanted data
  # upload customer registration
  # upload mandala data balance
  # upload floorsheet
  # upload payments mandala
  # upload sales
  # generate sales bills

  desc "Hack for the data fixes"
  task :fix_data, [:tenant] => :environment do |task, args|
    if args.tenant.present?
      tenant = args.tenant
      Rake::Task["smartkhata_data:clear_unwanted_old_data"].invoke(tenant)
      Rake::Task["smartkhata_data:upload_banks"].invoke(tenant)
      Rake::Task["smartkhata_data:import_opening_balance"].invoke(tenant)
      Rake::Task["patch_internal_opening_balances"].invoke(tenant)
      Rake::Task["smartkhata_data:upload_floorsheets"].invoke(tenant)
      Rake::Task["smartkhata_data:import_payment_receipts"].invoke(tenant)
      Rake::Task["smartkhata_data:import_cm05"].invoke(tenant)
      Rake::Task["smartkhata_data:generate_sales_bills"].invoke(tenant)
    else
      puts 'Please pass a tenant to the task'
    end
  end

  desc "Clear Unwanted Data"
  task :clear_unwanted_old_data, [:tenant] => :environment do |task, args|
    if args.tenant.present?
      tenant = args.tenant
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      UserSession.selected_fy_code= 7374
      UserSession.selected_branch_id = 1

      puts "Deleting file uploads.."
      FileUpload.delete_all

      puts "Deleting bills and vouchers.."
      BillVoucherAssociation.delete_all
      Settlement.unscoped.delete_all
      Voucher.delete_all
      Bill.unscoped.delete_all


      puts "Deleting Particulars and Cheque Entries ..."
      ChequeEntryParticularAssociation.delete_all
      ParticularsShareTransaction.unscoped.delete_all
      Particular.unscoped.delete_all
      LedgerBalance.unscoped.delete_all
      LedgerDaily.unscoped.delete_all
      ChequeEntry.unscoped.delete_all
      SalesSettlement.delete_all

      puts "Deleting Share Transactions"
      ShareTransaction.delete_all
      ShareInventory.delete_all

      puts "Deleting Order"
      Order.delete_all

    else
      puts 'Please pass a tenant to the task'
    end
  end

  desc "Uploads all floorsheet"
  task :upload_floorsheets, [:tenant] => :environment do |task,args|
    if args.tenant.present?
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      UserSession.selected_fy_code= 7374
      UserSession.selected_branch_id = 1

      puts "uploading floorsheets"

      month = 4;
      day = 2;

      end_month = 6;
      max_days = 32;

      while month <= end_month  do
        while day <= max_days do
          file_name = "BrokerwiseFloorSheetReport2073-#{month.to_s.rjust(2, '0')}-#{day.to_s.rjust(2, '0')}.xls"
          file = Rails.root.join('test_files', 'smartkhata_data_upload', args.tenant,'floorsheets', file_name)
          if File.exist? file

            floorsheet_upload = FilesImportServices::ImportFloorsheet.new(file)
            floorsheet_upload.process
            #
            puts floorsheet_upload.error_message
            puts "Total count for #{file_name} : #{floorsheet_upload.processed_data.size}"
          end
          day += 1
        end
        # reinitialize the day
        day = 1
        month +=1
      end
    else
      puts 'Please pass a tenant to the task'
    end
  end

  desc "Generates sales bill from the sales settlements"
  task :generate_sales_bills, [:tenant] => :environment do |task,args|
    if args.tenant.present?
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      UserSession.selected_branch_id = 1
      UserSession.selected_fy_code = 7374

      @sales_settlements = SalesSettlement.all

      puts "Generating sales bills .."
      @sales_settlements.each do |s|
        puts "Generating bills for settlement: #{s.settlement_id}"
        GenerateBillsService.new(sales_settlement: s).process if s.pending?
      end
      puts "Task completed "
      Apartment::Tenant.switch!('public')
    else
      puts 'Please pass a tenant to the task'
    end
  end

  desc "Upload mandala balance"
  task :import_opening_balance, [:tenant] => :environment do |task,args|
    if args.tenant.present?
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      UserSession.selected_branch_id = 1
      UserSession.selected_fy_code = 7374

      file = Rails.root.join('test_files', 'smartkhata_data_upload', args.tenant, 'account_balance.csv')
      # puts file
      # puts "Uploading account balance.."
      #
      file_upload_param = ActionDispatch::Http::UploadedFile.new(
         tempfile: File.new(file),
         filename: file.to_s
      )

      file_upload = SysAdminServices::ImportOpeningBalance.new(file_upload_param)
      file_upload.process
      file_upload.processed_data
      puts file_upload.error_message
      puts "Task completed " unless file_upload.error_message

      Apartment::Tenant.switch!('public')
    else
      puts 'Please pass a tenant to the task'
    end
  end

  desc "Upload mandala payment receipt"
  task :import_payment_receipts, [:tenant] => :environment do |task,args|
    if args.tenant.present?
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      UserSession.selected_branch_id = 1
      UserSession.selected_fy_code = 7374

      file = Rails.root.join('test_files', 'smartkhata_data_upload', args.tenant, 'receipt_payment.csv')
      # puts file
      puts "Uploading payment receipts.."
      #
      file_upload_param = ActionDispatch::Http::UploadedFile.new(
          tempfile: File.new(file),
          filename: file.to_s
      )

      file_upload = SysAdminServices::ImportPaymentsReceipts.new(file_upload_param)
      file_upload.process
      file_upload.processed_data
      puts file_upload.error_message
      puts "Task completed " unless file_upload.error_message

      Apartment::Tenant.switch!('public')
    else
      puts 'Please pass a tenant to the task'
    end
  end

  desc "Settle Bills"
  task :settle_bills, [:tenant] => :environment do |task,args|
    if args.tenant.present?
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      UserSession.selected_branch_id = 1
      UserSession.selected_fy_code = 7374
      @amount_margin_error = 0.01

      client_accounts = ClientAccount.all

      ActiveRecord::Base.transaction do
        client_accounts.each do |client_account|
          puts "processing for client account #{client_account.id}"
          ledger_balance = client_account.ledger.closing_balance

          bills_receive = client_account.bills.requiring_receive
          bills_payment = client_account.bills.requiring_payment

          amount_to_receive = bills_receive.sum(:balance_to_pay)
          amount_to_pay = bills_payment.sum(:balance_to_pay)

          # negative if the company has to pay
          # positive if the client needs to pay
          amount_to_receive_or_pay = amount_to_receive - amount_to_pay

          # case all bills are to be processed.
          if ledger_balance <= 0 && ledger_balance + @amount_margin_error >= 0
            bills_payment.update_all(balance_to_pay: 0, status: Bill.statuses[:settled])
            bills_receive.update_all(balance_to_pay: 0, status: Bill.statuses[:settled])
            # case when purchase amount in more than sales amount
        #   if account balance is negative settle all purchase bills
          elsif ledger_balance + @amount_margin_error < 0
            bills_receive.update_all(balance_to_pay: 0, status: Bill.statuses[:settled])

            available_amount = amount_to_pay + ledger_balance

            bills_payment.each do |bill|
              if bill.balance_to_pay.round(2)-@amount_margin_error <= available_amount
                available_amount = available_amount - bill.balance_to_pay
                bill.balance_to_pay = 0
                bill.status = Bill.statuses[:settled]
                bill.save!
              else
                break
              end
            end
          elsif ledger_balance - @amount_margin_error >= 0
            bills_payment.update_all(balance_to_pay: 0, status: Bill.statuses[:settled])

            available_amount = amount_to_receive - ledger_balance

            bills_receive.each do |bill|
              if bill.balance_to_pay.round(2)-@amount_margin_error <= available_amount
                available_amount = available_amount - bill.balance_to_pay
                bill.balance_to_pay = 0
                bill.status = Bill.statuses[:settled]
                bill.save!
              else
                break
              end
            end

          end


        end
      end

      Apartment::Tenant.switch!('public')
    else
      puts 'Please pass a tenant to the task'
    end
  end

  desc "Upload mandala sales payout"
  task :import_cm05, [:tenant] => :environment do |task,args|
    if args.tenant.present?
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      UserSession.selected_branch_id = 1
      UserSession.selected_fy_code = 7374

      file = Rails.root.join('test_files', 'smartkhata_data_upload', args.tenant, 'CM0501092016150833.csv')
      # puts file
      # puts "Uploading account balance.."
      #
      file_upload_param = ActionDispatch::Http::UploadedFile.new(
          tempfile: File.new(file),
          filename: file.to_s
      )

      file_upload = SysAdminServices::ImportPayout.new(file_upload_param)
      file_upload.process(true)
      file_upload.processed_data
      puts file_upload.error_message
      puts "Task completed " unless file_upload.error_message

      Apartment::Tenant.switch!('public')
    else
      puts 'Please pass a tenant to the task'
    end
  end

  desc "Upload bank codes"
  task :upload_banks, [:tenant] => :environment do |task, args|
    if args.tenant.present?
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      UserSession.selected_fy_code= 7374
      UserSession.selected_branch_id = 1

      puts "uploading banks"
      filename = Rails.root.join('test_files', 'smartkhata_data_upload', args.tenant,'bank_parameter.csv')

      count = 0
      CSV.foreach(filename, :headers => true) do |row|

        Bank.find_or_create_by!(bank_code: row['BANK_CODE']) do |b|
          b.name = row["BANK_NAME"]
          count += 1
        end

      end
      puts "#{count} Banks entered"

    else
      puts 'Please pass a tenant to the task'
    end
  end
end