namespace :share_transaction do
  # fix the transaction type
  desc "fix missing transaction_type"
  task :fix_transaction_type,[:tenant] => 'smartkhata:validate_tenant' do |task, args|
    Mandala::DailyTransaction.find_each do |x|
      x.share_transaction.update(transaction_type: x.sk_transaction_type) if x.share_transaction_id.present?
    end
    puts "updated share transactions"

    #patch the transaction type u
  end


  # duplicate share transactions
  # while migrating from the mandala there has been duplicates
  # delete the transactions and map their bill to the other share transaction
  desc "patch duplicate share transactions"
  task :merge_duplicates,[:tenant] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant

  #   check if there are missing transaction_type
    wrong_share_transaction_count = ShareTransaction.where(transaction_type: nil).count
    ActiveRecord::Base.transaction do
      if wrong_share_transaction_count <= 0
        Rake::Task["share_transaction:fix_transaction_type"].invoke(tenant)
      else

      end
    end

  end
end