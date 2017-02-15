namespace :client_account do
  desc "Fix name format of all client accounts."
  task :fix_format_of_names,[:tenant, :mimic] => 'smartkhata:validate_tenant' do |task, args|
    count = 0
    ActiveRecord::Base.transaction do
      ClientAccount.unscoped.find_each do |client_account|
        name_before = client_account.name.dup
        if name_before != client_account.format_name
          puts "Processing Client Account(id: #{client_account.id}) with name `#{client_account.name}`."
          client_account.skip_validation_for_system = true
          client_account.format_name
          client_account.save! unless args.mimic.present?
          count += 1
          puts "Client Account(id: #{client_account.id})'s name changed from `#{name_before}` to `#{client_account.name}`."
        end
      end
      puts "Total Client Account names formatted: #{count}"
    end
  end

  desc "Fix nepse code format of all client accounts."
  task :fix_format_of_nepse_codes,[:tenant, :mimic] => 'smartkhata:validate_tenant' do |task, args|
    count = 0
    ActiveRecord::Base.transaction do
      ClientAccount.unscoped.find_each do |client_account|
        if client_account.nepse_code.present?
          nepse_code_before = client_account.nepse_code.dup
          if nepse_code_before != client_account.format_nepse_code
            puts "Processing Client Account(id: #{client_account.id}) with nepse_code `#{client_account.nepse_code}`."
            client_account.skip_validation_for_system = true
            client_account.format_nepse_code
            client_account.save! unless args.mimic.present?
            count += 1
            puts "Client Account(id: #{client_account.id})'s nepse code changed from `#{nepse_code_before}` to `#{client_account.nepse_code}`."
          end
        end
      end
      puts "Total Client Account nepse codes formatted: #{count}"
    end
  end

  desc "Find client accounts with duplicate (case insensitive) nepse code."
  task :find_client_accounts_with_duplicate_nepse_code,[:tenant] => 'smartkhata:validate_tenant' do |task, args|
    search_hash = ClientAccount.unscoped.select("LOWER(nepse_code)").group("LOWER(nepse_code)").having("count(*) > 1").count
    search_hash.each do |nepse_code, occurrence|
      p "#{nepse_code} => #{occurrence}"
    end
  end
end

