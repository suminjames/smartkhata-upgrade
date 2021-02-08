class NchlPaymentsController < VisitorsController
  include SignTokenModule

  MerchantId = '303'
  AppId      = 'MER-303-APP-1'
  AppName    = 'Trishakti'

  def create
    @txn_amt      = params[:txnAmt]
    @txn_id       = 8024
    @txn_currency = "NPR"
    @ref_id       = 124
    @remarks      = 123455
    @particulars  = 12345

    data = "MERCHANTID=#{MerchantId},APPID=#{AppId},APPNAME=#{AppName},TXNID=#{@txn_id},TXNDATE=#{Date.today.to_s},TXNCRNCY=#{@txn_currency},TXNAMT=#{@txn_amt},REFERENCEID=#{@ref_id},REMARKS=#{@remarks},PARTICULARS=#{@particulars},TOKEN=TOKEN"

    signed_token = get_signed_token(data)

    render json: { signed_token: signed_token }
  end
end
