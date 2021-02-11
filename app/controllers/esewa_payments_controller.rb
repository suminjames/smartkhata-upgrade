class EsewaPaymentsController < VisitorsController
  include EsewaPaymentsHelper

  before_action :set_esewa_payment, only: [:failure]

  def index
    @esewa_payments = EsewaPayment.all
  end

  def create
    ActiveRecord::Base.transaction do
      @esewa_payment             = EsewaPayment.new(esewa_payment_params)
      @esewa_payment.success_url = get_success_url

      if @esewa_payment.save
        payment_transaction = PaymentTransaction.create(payment_transaction_params.merge(payable: @esewa_payment, amount: params['total_amount']))
        @esewa_payment.update(failure_url: get_failure_url + "&id=#{@esewa_payment.id}")

        if payment_transaction.persisted?
          render json: { payment: @esewa_payment, security_code: get_esewa_security_code }
        else
          raise ActiveRecord::Rollback
          render json: { msg: 'cannot save esewa payment transaction record' }
        end

      else
        render json: { msg: 'cannot save esewa payment record' }
      end
    end
  end

  def success
    @esewa_payment      = EsewaPayment.find(params[:oid])
    payment_transaction = @esewa_payment.payment_transaction

    if payment_transaction.status.nil?
      payment_transaction.set_response_received_time

      @esewa_payment.set_response_ref(params[:refId])
      @esewa_payment.set_response_amount(params[:amt])

      @verification_status = send_esewa_transaction_verification(@esewa_payment)
    end
  end

  def failure
    payment_transaction = @esewa_payment.payment_transaction
    payment_transaction.failure!
    payment_transaction.set_response_received_time
  end

  private

  def send_esewa_transaction_verification(payment)
    PaymentTransactions::Esewa::TransactionVerificationService.new(payment).call
  end

  def set_esewa_payment
    @esewa_payment = EsewaPayment.find(params[:id])
  end

  def esewa_payment_params
    params.permit(:amount, :service_charge, :delivery_charge, :tax_amount)
  end

  def payment_transaction_params
    params.permit(bill_ids: [])
  end
end
