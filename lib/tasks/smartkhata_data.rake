# This is purely hack to kickstart the smartkhata from given floorsheet files
# not to be confused with general purpose
# less time was dedicated for this task and will require code changes for reusability.

namespace :smartkhata_data do

  desc "Hack for the data fixes"
  task :fix_old_data, [:tenant] => :environment do |task, args|
    if args.tenant.present?
      tenant = args.tenant
      Rake::Task["smartkhata_data:clear_unwanted_old_data"].invoke(tenant)
      Rake::Task["smartkhata_data:generate_sales_bills"].invoke(tenant)
      Rake::Task["smartkhata_data:remove_sales_transaction_data"].invoke(tenant)
      Rake::Task["smartkhata_data:upload_floorsheets"].invoke(tenant)
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
      Particular.unscoped.delete_all
      ChequeEntry.unscoped.delete_all

      # delete buying transaction
      ShareTransaction.buying.delete_all
      # Remove the bill_id from sales transactions.
      ShareTransaction.selling.update_all(bill_id: nil)

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

      end_month = 5;
      max_days = 32;

      while month <= end_month  do
        while day <= max_days do
          file_name = "BrokerwiseFloorSheetReport2073-#{month.to_s.rjust(2, '0')}-#{day.to_s.rjust(2, '0')}.xls"
          file = Rails.root.join('test_files', 'floorsheet_upload', file_name)
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

  desc "Generates sales bill from the existing sales settlements"
  task :generate_sales_bills, [:tenant] => :environment do |task,args|
    if args.tenant.present?
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      @sales_settlements = SalesSettlement.all
      puts "Generating sales bills .."
      @sales_settlements.update_all(status: 'pending')

      @sales_settlements.each do |s|
        GenerateBillsService.new(sales_settlement: s).process
      end
      puts "Task completed "
      Apartment::Tenant.switch!('public')
    else
      puts 'Please pass a tenant to the task'
    end
  end

  desc "Remove sales inventory and selling transactions"
  task :remove_sales_transaction_data, [:tenant] => :environment do |task,args|
    if args.tenant.present?
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first

      ShareTransaction.selling.delete_all
      ShareInventory.delete_all

      puts "Removed sales inventory and selling transactions "
      Apartment::Tenant.switch!('public')
    else
      puts 'Please pass a tenant to the task'
    end
  end
end