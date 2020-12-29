class FloorsheetValueDateJob < ActiveJob::Base

  queue_as :default
  def perform(report_date, value_date)
    voucher_ids = BillVoucherAssociation.where(bill_id: Bill.where(date: report_date).select(:id)).select(:voucher_id)
    Particular.where(voucher_id: voucher_ids).find_each do |particular|
      particular.update(value_date: value_date)
    end
  end
end
