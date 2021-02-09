class NchlPaymentsController < VisitorsController
  include SignTokenModule

  MerchantId = '303'
  AppId      = 'MER-303-APP-1'
  AppName    = 'Trishakti'

  def create
    @txn_amt      = params[:txnAmt]
    @txn_id       = "8024"
    @txn_currency = "NPR"
    @ref_id       = "124"
    @remarks      = "123455"
    @particulars  = "12345"
    @txn_date     = Date.today.to_s

    data = "MERCHANTID=#{MerchantId},APPID=#{AppId},APPNAME=#{AppName},TXNID=#{@txn_id},TXNDATE=#{@txn_date},TXNCRNCY=#{@txn_currency},TXNAMT=#{@txn_amt},REFERENCEID=#{@ref_id},REMARKS=#{@remarks},PARTICULARS=#{@particulars},TOKEN=TOKEN"

    signed_token = get_signed_token(data)

    render json: {
        merchant_id:  MerchantId,
        app_id:       AppId,
        app_name:     AppName,
        txn_id:       @txn_id,
        txn_currency: @txn_currency,
        txn_date:     @txn_date,
        ref_id:       @ref_id,
        remarks:      @remarks,
        particulars:  @particulars,
        signed_token: signed_token
    }
  end
end
