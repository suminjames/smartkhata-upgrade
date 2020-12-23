desc "Interest related"
namespace :interest do
  task :for_yesterday, [:tenant] => 'smartkhata:validate_tenant' do |task,args|
    InterestParticular.calculate_interest
  end

  task :full_fiscal_year,[:tenant, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    fy_code = args.fy_code || current_fy_code
    ActiveRecord::Base.transaction do
      Particular.where(fy_code: fy_code).distinct(:value_date).each do |value_date|
        InterestParticular.calculate_interest(date: value_date)
      end
    end
  end
end
