
# Populate date column with date_ad that is equivalent to date_bs, which is already a column in the table.
task :fill_date_ad_in_settlement, [:tenant] => :environment do |task, args|
  # extend CustomDateModule
  # if args.tenant.present?
  #   Apartment::Tenant.switch!(args.tenant)
  #   UserSession.user = User.first
  #
  #   p "Selected Tenant: #{args.tenant}"
  #   p 'Seeding date in date column of Settlements table...'
  #
  #   Settlement.unscoped.find_each do |settlement|
  #     settlement.date = bs_to_ad(settlement.date_bs)
  #     p ''
  #     p "Date BS = #{settlement.date_bs}"
  #     p "Date AD = #{settlement.date}"
  #     settlement.save!
  #   end
  #   p 'Seeding date in date column of Settlements table...Completed!'
  # else
  #   puts 'Please pass a tenant to the task'
  # end
end
