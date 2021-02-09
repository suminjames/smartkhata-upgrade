class EsewaPaymentsController < VisitorsController
  include EsewaPaymentsHelper

  before_action :set_esewa_payment, only: [:show, :edit, :update, :destroy, :failure]

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
    @esewa_payment = EsewaPayment.find(params[:oid])

    @esewa_payment.success!

    @esewa_payment.set_response_received_time
    @esewa_payment.set_response_ref(params[:refId])
    @esewa_payment.set_response_amount(params[:amt])

    @verification_status = send_esewa_transaction_verification(@esewa_payment)
  end

  def failure
    @esewa_payment.fail!
    @esewa_payment.set_response_received_time
  end

  private
  def send_esewa_transaction_verification(payment)
    verification = payment.esewa_transaction_verifications.create
    PaymentTransactions::Esewa::TransactionVerificationService.new(verification).call
  end

  def set_esewa_payment
    @esewa_payment = EsewaPayment.find(params[:id])
  end

  def esewa_payment_params
    params.permit(:amount, :service_charge, :delivery_charge, :tax_amount, :total_amount, bill_ids: [])
  end
end
