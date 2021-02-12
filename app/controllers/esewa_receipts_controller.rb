class EsewaReceiptsController < VisitorsController
  include EsewaReceiptsHelper

  def index
    @esewa_receipts = EsewaReceipt.all
  end

  def create
    @esewa_receipt = EsewaReceipt.new(esewa_receipt_params.merge(success_url: get_success_url))

    @esewa_receipt.amount, @esewa_receipt.bill_ids = params['total_amount'], params[:bill_ids]

    if @esewa_receipt.save

      @esewa_receipt.update(failure_url: get_failure_url + "&oid=#{@esewa_receipt.get_transaction_id}")

      render json: { payment: @esewa_receipt, product_id: @esewa_receipt.get_transaction_id, security_code: get_esewa_security_code }
    else
      render json: { error: 'cannot save esewa payment transaction record' }
    end
  end

  private

  def esewa_receipt_params
    params.permit(:amount, :service_charge, :delivery_charge, :tax_amount)
  end

  def receipt_transaction_params
    params.permit(bill_ids: [])
  end
end
