
namespace :smartkhata_data do

  desc "Uploads all floorsheet"
  task :upload_floorsheets, [:tenant] => :environment do |task,args|
    if args.tenant.present?
      Apartment::Tenant.switch!(args.tenant)
      UserSession.user= User.first
      UserSession.selected_fy_code= 7374
      UserSession.selected_branch_id = 1

      app = ActionDispatch::Integration::Session.new(Rails.application)
      app.post "/files/floorsheets/import"

    else
      puts 'Please pass a tenant to the task'
    end
  end
end