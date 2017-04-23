namespace :branch do
  task :change_client_branch,[:tenant, :branch_id] => 'smartkhata:validate_tenant' do |task, args|
    branch_id = args.branch_id
    tenant = args.tenant

    ledger_ids = []
    ActiveRecord::Base.transaction do
      ClientAccount.where(branch_id: branch_id).find_each do |client_account|
        ledger = client_account.ledger

        LedgerDaily.unscoped.where(ledger_id: ledger.id).delete_all
        LedgerBalance.unscoped.where(ledger_id: ledger.id, branch_id: branch_id).delete_all
        LedgerBalance.unscoped.where(ledger_id: ledger.id, branch_id: 1).update_all(branch_id: branch_id)
        Particular.unscoped.where(ledger_id: ledger.id).update_all(branch_id: branch_id)

        Particular.unscoped.where(ledger_id: ledger.id).find_each do |particular|
          # this case fails in case of payment voucher
          voucher = particular.voucher
          other_particulars = Particular.unscoped.where(voucher_id: voucher.id)
          other_ledger_ids =  other_particulars.pluck(:ledger_id)
          if (Ledger.where(id: other_ledger_ids).where.not(client_account_id: nil).count == 1)
            other_particulars.update_all(branch_id: branch_id)
            ledger_ids += other_ledger_ids
          end
        end

        Bill.unscoped.where(client_account_id: client_account.id).update_all(branch_id: branch_id)
        Settlement.where(client_account_id: client_account.id).update_all(branch_id: branch_id)
        ledger_ids << ledger.id
      end

      Rake::Task["ledger:fix_ledger_selected"].invoke(tenant, ledger_ids.uniq.join(" "), true, branch_id)
      Rake::Task["ledger:fix_ledger_selected"].invoke(tenant, ledger_ids.uniq.join(" "), true)
    end
  end
end