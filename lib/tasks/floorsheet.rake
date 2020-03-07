namespace :floorsheet do
  # not a complete solution
  # used for date nov-13-2018
  task :rollback,[:tenant, :date_bs, :branch_id, :fy_code, :user_id ] => 'smartkhata:validate_tenant' do |task, args|
    tenant = args.tenant
    date_bs = args.date_bs
    branch_id = args.branch_id || 1
    fy_code = args.fy_code || 7677
    user_id = args.user_id || User.admin.first.id
    ActiveRecord::Base.transaction do
    #   first find bills
      bill_ids = TransactionMessage.by_branch(branch_id).where(transaction_date: date_bs).pluck(:bill_id).compact
      voucher_ids = BillVoucherAssociation.where(bill_id: bill_ids).pluck(:voucher_id)
      ShareTransaction.unscoped.by_branch_id(branch_id).where(bill_id: bill_ids).each do |st|
        share_inventory = ShareInventory.find_by(
          client_account_id: st.client_account_id,
          isin_info_id: st.isin_info_id
        )
        share_inventory.total_in -= st.quantity
        share_inventory.floorsheet_blnc -= st.quantity
        share_inventory.current_user_id = user_id
        share_inventory.save!
      end

      ShareTransaction.where(bill_id: bill_ids).delete_all
      ShareTransaction.where(date: date_bs).selling.delete_all

      ledger_ids = Particular.unscoped.by_branch_fy_code(branch_id, fy_code).where(voucher_id: voucher_ids).pluck(:ledger_id).uniq

      Particular.unscoped.by_branch_fy_code(branch_id, fy_code).where(voucher_id: voucher_ids).delete_all

      BillVoucherAssociation.where(bill_id: bill_ids).delete_all
      Voucher.by_branch_fy_code(branch_id, fy_code).where(id: voucher_ids).delete_all

      SmsMessage.by_branch_fy_code(branch_id, fy_code).where(transaction_message_id: TransactionMessage.by_branch(branch_id).where(transaction_date: date_bs).pluck(:id)).delete_all
      TransactionMessage.where(transaction_date: date_bs).delete_all

      Bill.by_branch_fy_code(branch_id, fy_code).where(id: bill_ids).delete_all

      Ledger.by_fy_code(fy_code).by_branch_id(branch_id).where(id: ledger_ids).find_each do |ledger|
        Accounts::Ledgers::PopulateLedgerDailiesService.new.patch_ledger_dailies(ledger, false, user_id, branch_id, fy_code)
        Accounts::Ledgers::ClosingBalanceService.new.patch_closing_balance(ledger, all_fiscal_years: false, branch_id: branch_id, fy_code: fy_code, current_user_id: user_id)
      end
    end
  end
end

