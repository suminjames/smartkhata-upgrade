require "net/http"
require 'open-uri'

class PaymentTransaction::Nchl
  include SignTokenModule

  MerchantId = '303'
  AppId      = 'MER-303-APP-1'
  AppName    = 'Trishakti'

  def initialize(transaction_amt)
    @transaction_amt = transaction_amt
    @txn_id          = 8024
    @txn_currency    = "NPR"
    @ref_id          = 124
    @remarks         = 123455
    @particulars     = 12345
  end

  def connect_ips
    data = "MERCHANTID=#{MerchantId},APPID=#{AppId},APPNAME=#{AppName},TXNID=#{@txn_id},TXNDATE=#{Date.today.to_s},TXNCRNCY=#{@txn_currency},TXNAMT=#{@transaction_amt},REFERENCEID=#{@ref_id},REMARKS=#{@remarks},PARTICULARS=#{@particulars},TOKEN=TOKEN"

    uri     = URI.parse("https://uat.connectips.com/connectipswebgw/loginpage")
    request = Net::HTTP::Post.new(uri.request_uri)

    parameters = {
        MERCHANTID:  MerchantId,
        APPID:       AppId,
        APPNAME:     AppName,
        TXNID:       @txn_id,
        TXNDATE:     Date.today.to_s,
        TXNCRNCY:    @txn_currency,
        TXNAMT:      @transaction_amt,
        REFERENCEID: @ref_id,
        REMARKS:     @remarks,
        PARTICULARS: @particulars,
        TOKEN:       get_signed_token(data),
    }
    request.set_form_data(parameters)

    response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
      http.request(request)
    end

    response.body
  end
end