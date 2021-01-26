desc "Interest related"
namespace :interest do
  task :for_yesterday, [:tenant] => 'smartkhata:validate_tenant' do |task,args|
    ActiveRecord::Base.transaction do
      InterestParticular.calculate_interest
      puts "#{Time.current.to_date} : Sucessfully Ran interest calculation"
    end
  end

  task :for_yesterday_trishakti do
    Rake::Task["interest:for_yesterday"].invoke('trishakti')
  end

  task :full_fiscal_year,[:tenant, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    fy_code = args.fy_code || current_fy_code

    (fiscal_year_start_date(fy_code) .. Date.current).each do |date|
      ActiveRecord::Base.transaction do
        InterestParticular.calculate_interest(date: date)
      end
    end
  end


  task :from_date, [:tenant, :date] =>'smartkhata:validate_tenant' do |task, args|
    fy_code = args.fy_code || current_fy_code
    value_date = args.date.to_date
    final_date =  fiscal_year_last_day(fy_code)
    (value_date .. [[value_date, Date.current].max, final_date].min).each do |date|
      ActiveRecord::Base.transaction do
        InterestParticular.calculate_interest(date: date)
      end
    end
  end
end
