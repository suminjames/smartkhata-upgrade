class FloorsheetValueDateJob < ActiveJob::Base

  queue_as :default
  def perform(report_date, value_date)
    voucher_ids = BillVoucherAssociation.where(bill_id: Bill.purchase.where(date: report_date).select(:id)).select(:voucher_id)

    default_ledger_names = ["Purchase Commission", "Sales Commission", "Nepse Purchase", "Nepse Sales","TDS","DP Fee/ Transfer"]
    Particular
      .where(voucher_id: voucher_ids)
      .where.not(ledger_id: Ledger.where(name: default_ledger_names).select(:id))
      .find_each do |particular|
      particular.update(value_date: value_date)
    end
  end
end
