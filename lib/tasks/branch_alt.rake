namespace :branch_alt do
  task :change_client_branch,[:tenant, :branch_id, :date_bs] => 'smartkhata:validate_tenant' do |task, args|
    branch_id = args.branch_id
    tenant = args.tenant
    ledger_ids = []
    ActiveRecord::Base.transaction do
      ClientAccount.where(branch_id: branch_id).find_each do |client_account|

        ledger = client_account.ledger
        particulars = Particular.unscoped.where(branch_id: 1, ledger_id: ledger.id)
        Bill.unscoped.where(client_account_id: client_account.id).update_all(branch_id: branch_id)
        Settlement.where(client_account_id: client_account.id).update_all(branch_id: branch_id)
        particulars.update_all(branch_id: branch_id)
        particulars.find_each do |particular|
          # # this case fails in case of payment voucher
          voucher = particular.voucher
          other_particulars = Particular.unscoped.where(voucher_id: voucher.id)
          other_ledger_ids =  other_particulars.pluck(:ledger_id)
          if (Ledger.where(id: other_ledger_ids).where.not(client_account_id: nil).count == 1)
            other_particulars.update_all(branch_id: branch_id)
            ledger_ids += other_ledger_ids
          end
        end
        ledger_ids << ledger.id
      end
      unless ledger_ids.blank?
        Rake::Task["ledger:fix_ledger_selected"].invoke(tenant, ledger_ids.uniq.join(" "), true, branch_id)
        Rake::Task["ledger:fix_ledger_selected"].reenable
        Rake::Task["ledger:fix_ledger_selected"].invoke(tenant, ledger_ids.uniq.join(" "), true)
      end
    end
  end
end