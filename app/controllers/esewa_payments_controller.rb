class EsewaPaymentsController < VisitorsController
  include EsewaPaymentsHelper

  before_action :set_esewa_payment, only: [:show, :edit, :update, :destroy]

  def index
    @esewa_payments = EsewaPayment.all
  end

  def create
    @esewa_payment = EsewaPayment.new(esewa_payment_params)
    @esewa_payment.success_url  = get_success_url

    if @esewa_payment.save
      @esewa_payment.update(failure_url: get_failure_url + "&id=#{@esewa_payment.id}")
      render json: {payment: @esewa_payment, security_code: get_esewa_security_code}
    else
      render json: {msg: 'cannot save esewa payment record'}
    end
  end

  def success

  end

  def failure

  end

  private

  def set_esewa_payment
    @esewa_payment = EsewaPayment.find(params[:id])
  end

  def esewa_payment_params
    params.permit(:amount, :service_charge, :delivery_charge, :tax_amount, :total_amount, bill_ids: [])
  end
end
