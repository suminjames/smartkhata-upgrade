class PaymentTransactionsController < VisitorsController

  def initiate_payment
    PaymentTransaction.create()
  end

  private


end
