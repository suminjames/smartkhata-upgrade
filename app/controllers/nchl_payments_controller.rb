class NchlPaymentsController < VisitorsController
  include SignTokenModule

  def create
    signed_token = build_payload_and_get_token

    nchl_payment = NchlPayment.new(
        reference_id: @ref_id,
        remarks:      @remarks,
        particular:   @particulars,
        token:        signed_token
    )

    nchl_payment.amount,
        nchl_payment.bill_ids,
        nchl_payment.transaction_id,
        nchl_payment.transaction_date = params[:amount], params[:bill_ids], @txn_id, @txn_date

    if nchl_payment.save
      render json: {
          merchant_id:  NchlPayment::MerchantId,
          app_id:       NchlPayment::AppId,
          app_name:     NchlPayment::AppName,
          txn_id:       nchl_payment.receipt_transaction.transaction_id,
          txn_currency: @txn_currency,
          txn_date:     nchl_payment.receipt_transaction.transaction_date,
          ref_id:       nchl_payment.reference_id,
          remarks:      nchl_payment.remarks,
          particulars:  nchl_payment.particular,
          signed_token: nchl_payment.token
      }
    else
      render json: { error: 'cannot save nchl payment transaction record' }
    end

  end

  def success
    get_receipt_transaction

    # this check is to make sure that the verification request is not sent again when the page is reloaded
    # as a previous payment_verification process would already have set the status of the transaction
    if @receipt_transaction.status.nil?
      response = payment_validation @receipt_transaction
      handle_validation_response @receipt_transaction, response
    end
  end

  def failure
    get_receipt_transaction
    @receipt_transaction.failure!
  end

  def get_receipt_transaction
    txn_id               = params[:TXNID]
    @receipt_transaction = ReceiptTransaction.find_by(transaction_id: txn_id)
    @receipt_transaction.set_response_received_time
  end

  def payment_validation receipt_transaction
    ReceiptTransactions::Nchl::PaymentValidation.new(receipt_transaction).validate
  end

  def build_payload_and_get_token
    @txn_amt      = params[:amount]
    @txn_id       = SecureRandom.hex(10)
    @txn_currency = "NPR"
    @ref_id       = "124"
    @remarks      = "123455"
    @particulars  = "12345"
    @txn_date     = Date.today.to_s

    data = "MERCHANTID=#{NchlPayment::MerchantId},APPID=#{NchlPayment::AppId},APPNAME=#{NchlPayment::AppName},TXNID=#{@txn_id},TXNDATE=#{@txn_date},TXNCRNCY=#{@txn_currency},TXNAMT=#{@txn_amt},REFERENCEID=#{@ref_id},REMARKS=#{@remarks},PARTICULARS=#{@particulars},TOKEN=TOKEN"

    get_signed_token(data)
  end

  def handle_validation_response receipt_transaction, response
    response["status"] == "SUCCESS" ? receipt_transaction.success! : receipt_transaction.fraudulent!
  end

  private

  def receipt_transaction_params
    params.permit(:amount, bill_ids: [])
  end
end
