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
        receipt_transaction = nchl_payment.build_payment_transaction(payment_transaction_params.merge(transaction_id: @txn_id, transaction_date: @txn_date, request_sent_at: Time.now))

        if receipt_transaction.save
          render json: {
              merchant_id:  MerchantId,
              app_id:       AppId,
              app_name:     AppName,
              txn_id:       receipt_transaction.transaction_id,
              txn_currency: @txn_currency,
              txn_date:     receipt_transaction.transaction_date,
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

    # this check is to make sure that the verification request is not sent again when the page is reloaded
    # as a previous payment_verification process would already have set the status of the transaction
    if @receipt_transaction.status.nil?
      response = payment_validation @receipt_transaction
      handle_validation_response @receipt_transaction, response
    end
  end

  def failure
    get_payment_transaction
    @receipt_transaction.failure!
  end

  def get_payment_transaction
    txn_id               = params[:TXNID]
    @receipt_transaction = ReceiptTransaction.find_by(transaction_id: txn_id)
    @receipt_transaction.set_response_received_time
  end

  def payment_validation receipt_transaction
    ReceiptTransactions::Nchl::PaymentValidation.new(receipt_transaction).validate
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

  def handle_validation_response receipt_transaction, response
    response["status"] == "SUCCESS" ? receipt_transaction.success! : receipt_transaction.fraudulent!
  end

  private

  def payment_transaction_params
    params.permit(:amount, bill_ids: [])
  end
end
