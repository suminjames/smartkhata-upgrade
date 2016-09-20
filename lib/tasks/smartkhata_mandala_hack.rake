# hack to fix data in smarthata in reference to mandala
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
    if args.tenant.present?
      tenant = args.tenant
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      UserSession.selected_fy_code= 7374
      UserSession.selected_branch_id = 1





    else
      puts 'Please pass a tenant to the task'
    end
  end
end
