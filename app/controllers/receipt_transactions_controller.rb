class ReceiptTransactionsController < VisitorsController
  def initiate_payment
    all_bills = Bill.where(id: params[:bill_ids])

    @bills = all_bills.decorate
    @total_amount = all_bills.sum(:net_amount).ceil(0)
    @bill_ids = params[:bill_ids]

    @esewa_payment_url = EsewaPayment::PAYMENT_URL
    @nchl_payment_url = NchlPayment::PAYMENT_URL
  end
end