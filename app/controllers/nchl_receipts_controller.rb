class NchlReceiptsController < VisitorsController
  include SignTokenModule

  def create
    signed_token = build_payload_and_get_token

    nchl_receipt = NchlReceipt.new(
        reference_id: @ref_id,
        remarks:      @remarks,
        particular:   @particulars,
        token:        signed_token
    )

    nchl_receipt.amount,
        nchl_receipt.bill_ids,
        nchl_receipt.transaction_id,
        nchl_receipt.transaction_date = params[:amount], params[:bill_ids], @txn_id, @txn_date

    if nchl_receipt.save
      render json: {
          merchant_id:  NchlReceipt::MerchantId,
          app_id:       NchlReceipt::AppId,
          app_name:     NchlReceipt::AppName,
          txn_id:       nchl_receipt.receipt_transaction.transaction_id,
          txn_currency: @txn_currency,
          txn_date:     nchl_receipt.receipt_transaction.transaction_date,
          ref_id:       nchl_receipt.reference_id,
          remarks:      nchl_receipt.remarks,
          particulars:  nchl_receipt.particular,
          signed_token: nchl_receipt.token
      }
    else
      render json: { error: 'cannot save nchl payment transaction record' }
    end
  end

  def build_payload_and_get_token
    @txn_amt      = params[:amount]
    @txn_id       = SecureRandom.hex(10)
    @txn_currency = "NPR"
    @ref_id       = "124"
    @remarks      = "123455"
    @particulars  = "12345"
    @txn_date     = Date.today.to_s

    data = "MERCHANTID=#{NchlReceipt::MerchantId},APPID=#{NchlReceipt::AppId},APPNAME=#{NchlReceipt::AppName},TXNID=#{@txn_id},TXNDATE=#{@txn_date},TXNCRNCY=#{@txn_currency},TXNAMT=#{@txn_amt},REFERENCEID=#{@ref_id},REMARKS=#{@remarks},PARTICULARS=#{@particulars},TOKEN=TOKEN"

    get_signed_token(data)
  end

  private

  def receipt_transaction_params
    params.permit(:amount, bill_ids: [])
  end
end
