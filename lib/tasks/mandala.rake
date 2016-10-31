namespace :mandala do
  desc "upload mandala data"
  task :upload_data, [:tenant] => :environment do |task, args|
    if args.tenant.present?

      tenant = args.tenant
      Apartment::Tenant.switch!(args.tenant)

      mandala_files = [
        # "account_balance",
        # "agm",
        # "bank_parameter",
        # "bill",
        # "bill_detail",
        # 'broker_parameter',
        # 'buy_settlement',
        # 'calendar_parameter',
        # 'capital_gain_detail',
        # "capital_gain_para",
        # "chart_of_account",
        # "commission_rate",
        # "commission",
        # "company_parameter_list",
        # "company_parameter",
        # "customer_child_info",
        # "customer_ledger"
        # "customer_registration",
        # "customer_registration_detail",
        # "daily_certificate",
        # "daily_transaction_no",
        # "daily_transaction",
        # "district_para",
        # "fiscal_year_para",
        # "ledger",
        # "mobile_message",
        # "organisation_parameter",
        "payout_upload",
      ]

      mandala_files.each do |file_name|
        file = Rails.root.join('test_files', 'mandala', args.tenant, "#{file_name}.csv")
        "Mandala::#{file_name.classify}".constantize.delete_all

        # count = 0
        CSV.foreach(file, :headers => true, :header_converters => [:downcase]) do |row|
          # break if count > 100
          # count = count + 1
          puts "entering data for #{row[0]}"
          "Mandala::#{file_name.classify}".constantize.create!(row.to_hash)
        end
      end
    else
      puts 'Please pass a tenant to the task'
    end
  end
end