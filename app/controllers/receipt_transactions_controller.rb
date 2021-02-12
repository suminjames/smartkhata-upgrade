class ReceiptTransactionsController < VisitorsController
  def initiate_payment
    all_bills = Bill.where(id: params[:bill_ids])

    @bills        = all_bills.decorate
    @total_amount = all_bills.sum(:net_amount).ceil(0)
    @bill_ids     = params[:bill_ids]

    @esewa_receipt_url = EsewaReceipt::PAYMENT_URL
    @nchl_receipt_url  = NchlReceipt::PAYMENT_URL
  end
end