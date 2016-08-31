desc "Generates sales bill from the existing sales settlements"
task :generate_sales_bills, [:tenant] => :environment do |task,args|
  if args.tenant.present?
    Apartment::Tenant.switch!(args.tenant)
    UserSession.user= User.first

    @sales_settlements = SalesSettlement.all
    @sales_settlements.each do |s|
      next if s.pending?

      # process the sale settlement
      GenerateBillsService.new(sales_settlement: s).process
    end
    puts "Task completed "
    Apartment::Tenant.switch!('public')
  else
    puts 'Please pass a tenant to the task'
  end
end