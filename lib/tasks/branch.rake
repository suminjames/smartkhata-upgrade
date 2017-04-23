namespace :branch do
  task :change_client_branch,[:tenant, :branch_id] => 'smartkhata:validate_tenant' do |task, args|
    branch_id = args.branch_id
    tenant = args.tenant

    ledger_ids = []
    ActiveRecord::Base.transaction do
      ClientAccount.where(branch_id: branch_id).find_each do |client_account|
        ledger = client_account.ledger

        # make sure it is not migrated already,
        # only way to ensure is that currently, it should not have particulars for default branch
        # also make sure the ledger being changed doesnot have opening balance

        ledger_balances = LedgerBalance.unscoped.where(ledger_id: ledger.id, branch_id: branch_id)
        opening_balance_set_for_branch = false
        ledger_balances.each { |b| (opening_balance_set_for_branch = true; break ) if b.opening_balance > 0 }
        break if opening_balance_set_for_branch

        if Particular.unscoped.where(ledger_id: ledger.id, branch_id: 1).count > 0
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
      end



      unless ledger_ids.blank?
        Rake::Task["ledger:fix_ledger_selected"].invoke(tenant, ledger_ids.uniq.join(" "), true, branch_id)
        Rake::Task["ledger:fix_ledger_selected"].invoke(tenant, ledger_ids.uniq.join(" "), true)
      end

    end
  end
end