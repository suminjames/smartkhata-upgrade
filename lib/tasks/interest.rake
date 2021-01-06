desc "Interest related"
namespace :interest do
  task :for_yesterday, [:tenant] => 'smartkhata:validate_tenant' do |task,args|
    ActiveRecord::Base.transaction do
      InterestParticular.calculate_interest
    end
  end

  task :full_fiscal_year,[:tenant, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    fy_code = args.fy_code || current_fy_code

    (fiscal_year_start_date(fy_code) .. Date.current).each do |date|
      ActiveRecord::Base.transaction do
        InterestParticular.calculate_interest(date: date)
      end
    end
  end
end
