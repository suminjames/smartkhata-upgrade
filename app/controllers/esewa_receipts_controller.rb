class EsewaReceiptsController < VisitorsController
  include EsewaReceiptsHelper

  def create
    @esewa_receipt = EsewaReceipt.new(esewa_receipt_params.merge(success_url: get_success_url, failure_url: get_failure_url))

    if @esewa_receipt.save
      render json: { payment: @esewa_receipt, product_id: @esewa_receipt.transaction_id, security_code: get_esewa_security_code }
    else
      render json: { error: 'cannot save esewa payment transaction record' }
    end
  end

  private

  def esewa_receipt_params
    params.permit(:amount, :service_charge, :delivery_charge, :tax_amount, :total_amount, bill_ids:[])
  end
end