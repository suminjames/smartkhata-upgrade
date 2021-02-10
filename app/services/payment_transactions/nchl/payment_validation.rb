require "net/http"

module PaymentTransactions
  module Nchl
    class PaymentValidation
      include SignTokenModule

      MerchantId = '303'
      AppId      = 'MER-303-APP-1'

      def initialize(transaction_amt, reference_id)
        @transaction_amt = transaction_amt
        @ref_id          = reference_id
      end

      def validate
        data = "MERCHANTID=#{MerchantId},APPID=#{AppId},REFERENCEID=#{@ref_id},TXNAMT=#{@transaction_amt}"

        uri     = URI.parse("https://uat.connectips.com/connectipswebws/api/creditor/validatetxn")
        request = Net::HTTP::Post.new(uri.request_uri)
        request.basic_auth AppId, Rails.application.secrets.nchl_basic_auth_pw
        request.content_type = 'application/json'

        parameters = {
            merchantId:  MerchantId,
            appId:       AppId,
            referenceId: @ref_id,
            txnAmt:      @transaction_amt,
            token:       get_signed_token(data)
        }

        request.body = parameters.to_json

        response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
          http.request(request)
        end

        response.body
      end
    end
  end
end