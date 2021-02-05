require 'net/http'

class PaymentTransaction::Nchl
  include ::SignedDataModule

  MerchantId = '303'
  AppId      = 'MER-303-APP-1'
  AppName    = 'Trishakti'

  def initialize(transaction_amt)
    @transaction_amt = transaction_amt
  end

  def run
    data = "MERCHANTID=#{MerchantId},APPID=#{AppId},APPNAME=#{AppName},TXNID=8024,TXNDATE=#{Date.today.to_s},TXNCRNCY=NPR,TXNAMT=#{@transaction_amt},REFERENCEID=124,REMARKS=123455,PARTICULARS=12345,TOKEN=TOKEN"

    uri                     = URI.parse("https://uat.connectips.com/connectipswebgw/loginpage")
    request                 = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"

    parameters = {
        MERCHANTID:  MerchantId,
        APPID:       AppId,
        APPNAME:     AppName,
        TXNID:       '8024',
        TXNDATE:     Date.today.to_s,
        TXNCRNCY:    'NPR',
        TXNAMT:      @transaction_amt,
        REFERENCEID: '124',
        REMARKS:     '123455',
        PARTICULARS: '12345',
        TOKEN:       get_signed_token(data),
    }
    binding.pry
    request.body = parameters.to_json

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    JSON.parse(response.body)

  end
end