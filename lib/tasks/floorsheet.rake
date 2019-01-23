namespace :floorsheet do
  # not a complete solution
  # used for date nov-13-2018
  task :rollback,[:tenant, :date_bs] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    date_bs = args.date_bs

    ActiveRecord::Base.transaction do
    #   first find bills
      bill_ids = TransactionMessage.where(transaction_date: date_bs).pluck(:bill_id).compact
      voucher_ids = BillVoucherAssociation.where(bill_id: bill_ids).pluck(:voucher_id)

      ShareTransaction.unscoped.where(bill_id: bill_ids).each do |st|
        share_inventory = ShareInventory.find_by(
          client_account_id: st.client_account_id,
          isin_info_id: st.isin_info_id
        )
        share_inventory.total_in -= st.quantity
        share_inventory.floorsheet_blnc -= st.quantity
        share_inventory.save!
      end

      ShareTransaction.where(bill_id: bill_ids).delete_all
      ShareTransaction.where(date: date_bs).selling.delete_all


      ledger_ids = Particular.unscoped.where(voucher_id: voucher_ids).pluck(:ledger_id).uniq

      Particular.unscoped.where(voucher_id: voucher_ids).delete_all


      BillVoucherAssociation.where(bill_id: bill_ids).delete_all
      Voucher.where(id: voucher_ids).delete_all

      SmsMessage.where(transaction_message_id: TransactionMessage.where(transaction_date: date_bs).pluck(:id)).delete_all

      TransactionMessage.where(transaction_date: date_bs).delete_all

      Bill.where(id: bill_ids).delete_all


      [1,2].each do |branch_id|
        Ledger.where(id: ledger_ids).find_each do |ledger|
          Accounts::Ledgers::PopulateLedgerDailiesService.new.patch_ledger_dailies(ledger, false, branch_id)
          Accounts::Ledgers::ClosingBalanceService.new.patch_closing_balance(ledger, all_fiscal_years: false, branch_id: branch_id)
        end
      end
    end
  end
end

