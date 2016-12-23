namespace :mandala do
  desc "Update missing share transactions, which occurred while running mandala data migration to SmartKhata."
  # Missing share transactions(and their corresponding bills) can occur for days whose payout report haven't been
  # uploaded. For instance. If the migration occured for data taken Friday evening, share transactions(and their
  # corresponding bills) for days Wednesday and Thursday will not be accounted for during the migration.
  task :create_missing_mandala_sales_share_transactions, [:tenant] => :environment do |task, args|
    include CustomDateModule
    include CommissionModule
    include ShareInventoryModule
    include ApplicationHelper

    if args.tenant.blank? || args.tenant != 'dipshikha'
      fail "Invalid tenant! This migration can apparently only be run in dipskhika tenant as of now."
    end

    Apartment::Tenant.switch!(args.tenant)
    UserSession.set_console('dipshikha')

    # relevant share transactions
    share_transactions =  Mandala::DailyTransaction.where(:transaction_date => ['14-DEC-16', '15-DEC-16'], :transaction_type => 'S')

    ActiveRecord::Base.transaction do
      share_transactions.each_with_index do |share_transaction, index|
        # Create Share Transaction
        new_share_transaction = ShareTransaction.new
        p index + 1
      end
    end

    Apartment::Tenant.switch!('public')
  end

end
