class NchlPaymentsController < VisitorsController
  include SignTokenModule

  MerchantId = '303'
  AppId      = 'MER-303-APP-1'
  AppName    = 'Trishakti'

  def create
    signed_token = build_payload_and_get_token

    ActiveRecord::Base.transaction do
      nchl_payment = NchlPayment.create(
          reference_id: @ref_id,
          remarks:      @remarks,
          particular:   @particulars,
          token:        signed_token
      )

      if nchl_payment.persisted?
        payment_transaction = nchl_payment.build_payment_transaction(payment_transaction_params.merge(transaction_id: @txn_id, transaction_date: @txn_date))

        if payment_transaction.save
          render json: {
              merchant_id:  MerchantId,
              app_id:       AppId,
              app_name:     AppName,
              txn_id:       payment_transaction.transaction_id,
              txn_currency: @txn_currency,
              txn_date:     payment_transaction.transaction_date,
              ref_id:       nchl_payment.reference_id,
              remarks:      nchl_payment.remarks,
              particulars:  nchl_payment.particular,
              signed_token: nchl_payment.token
          }
        else
          raise ActiveRecord::Rollback
          render json: { msg: 'cannot save nchl payment transaction record' }
        end

      else
        render json: { msg: 'cannot save nchl payment record' }
      end
    end
  end

  def success
    get_payment_transaction

    if @payment_transaction.status.nil?
      response = payment_validation @payment_transaction
      handle_validation_response @payment_transaction, response
    end
  end

  def failure
    get_payment_transaction
    @payment_transaction.failure!
  end

  def get_payment_transaction
    txn_id               = params[:TXNID]
    @payment_transaction = PaymentTransaction.find_by(transaction_id: txn_id)
    @payment_transaction.set_response_received_time
  end

  def payment_validation payment_transaction
    PaymentTransactions::Nchl::PaymentValidation.new(payment_transaction).validate
  end

  def build_payload_and_get_token
    @txn_amt      = params[:amount]
    @txn_id       = (0 .. 9).to_a.sample(6).join
    @txn_currency = "NPR"
    @ref_id       = "124"
    @remarks      = "123455"
    @particulars  = "12345"
    @txn_date     = Date.today.to_s

    data = "MERCHANTID=#{MerchantId},APPID=#{AppId},APPNAME=#{AppName},TXNID=#{@txn_id},TXNDATE=#{@txn_date},TXNCRNCY=#{@txn_currency},TXNAMT=#{@txn_amt},REFERENCEID=#{@ref_id},REMARKS=#{@remarks},PARTICULARS=#{@particulars},TOKEN=TOKEN"

    get_signed_token(data)
  end

  def handle_validation_response payment_transaction, response
    response["status"] == "SUCCESS" ? payment_transaction.success! : payment_transaction.fraudulent!
  end

  private

  def payment_transaction_params
    params.permit(:amount, bill_ids: [])
  end
end
