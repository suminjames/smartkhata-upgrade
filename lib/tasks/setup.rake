namespace :setup do
  task :validate_tenant, [:tenant] => :environment  do |task, args|
    abort 'Please pass a tenant name' unless args.tenant.present?
    tenant = args.tenant
    Apartment::Tenant.switch!(args.tenant)
    UserSession.selected_branch_id = 1
    UserSession.selected_fy_code = 7374
    UserSession.user = User.first
  end


  desc "populate commissions"
  task :commission, [:tenant] => 'mandala:validate_tenant' do |task, args|

    commission_rate = MasterSetup::CommissionInfo.new(start_date: Date.parse('2011-01-01'), end_date: '2016-07-23', nepse_commission_rate: 0.25)

    commission_details = MasterSetup::CommissionDetail.create([
                                         {start_amount: 0, limit_amount: 2500, commission_amount: 25},
                                         {start_amount: 2500, limit_amount: 50000.0, commission_rate: 1.0},
                                         {start_amount: 50000, limit_amount: 500000.0, commission_rate: 0.9},
                                         {start_amount: 500000.0, limit_amount: 1000000.0, commission_rate: 0.8},
                                         {start_amount: 	1000000.0, limit_amount: 99999999999.0, commission_rate: 0.7},
                                     ])

    commission_rate.commission_details << commission_details
    commission_rate.save!


    commission_rate = MasterSetup::CommissionInfo.new(start_date: Date.parse('2016-07-24'), end_date: '2021-12-31', nepse_commission_rate: 0.2)

    commission_details = MasterSetup::CommissionDetail
                             .create([
                                 {start_amount: 0, limit_amount: 4166.67, commission_amount: 25},
                                 {start_amount: 4166.67, limit_amount: 50000.0, commission_rate: 0.65},
                                 {start_amount: 50000, limit_amount: 500000.0, commission_rate: 0.55},
                                 {start_amount: 500000.0, limit_amount: 2000000.0, commission_rate: 0.5},
                                 {start_amount: 2000000.0, limit_amount: 	10000000.0, commission_rate: 0.45},
                                 {start_amount: 	10000000.0, limit_amount: 99999999999.0, commission_rate: 0.4},
                                     ])

    commission_rate.commission_details << commission_details
    commission_rate.save!


  end
end

