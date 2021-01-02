namespace :data do
  desc "Clear Unwanted Data"
  task :cleanup, [:tenant, :fy_code] => 'smartkhata:validate_tenant' do |task, args|
    fy_code = args.fy_code
    fy_start = fiscal_year_start_date(fy_code)

    puts "Deleting file uploads.."
    FileUpload.where('created_at < ?', fy_start).delete_all

    puts "Deleting Particulars and Cheque Entries ..."
    particulars = Particular.where.not(fy_code: fy_code)
    cheque_entries_id = ChequeEntryParticularAssociation.where(particular_id: particulars.select(:id)).pluck(:cheque_entry_id)
    ChequeEntryParticularAssociation.where(particular_id: particulars.select(:id)).delete_all
    ChequeEntry.where(id: cheque_entries_id).delete_all
    cheque_entries_id = []

    ParticularsShareTransaction.where(particular_id: particulars.select(:id)).delete_all
    particulars.delete_all
    LedgerBalance.where.not(fy_code: fy_code).delete_all
    LedgerDaily.where.not(fy_code: fy_code).delete_all

    puts "Deleting Share Transactions"
    ShareTransaction.where('date < ?', fy_start).delete_all
    # ShareInventory.delete_all

    puts "Deleting bills and vouchers.."
    bills = Bill.where.not(fy_code: fy_code)
    vouchers = Voucher.where.not(fy_code: fy_code)
    BillVoucherAssociation.where(voucher_id: vouchers.select(:id)).delete_all
    settlements = Settlement.where.not(fy_code: fy_code)
    ParticularSettlementAssociation.where(settlement_id: settlements.select(:id)).delete_all
    settlements.delete_all
    vouchers.delete_all
    bills.delete_all

    puts "Deleting Order"
    Order.where.not(fy_code: fy_code).delete_all

    Audited::Audit.delete_all

    # puts "Vaccuming"
    # ActiveRecord::Base.connection.execute('VACUUM FULL;')
  end
end
