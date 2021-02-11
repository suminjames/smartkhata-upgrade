require "net/http"

module PaymentTransactions
  module Nchl
    class PaymentValidation
      include SignTokenModule

      MerchantId = '303'
      AppId      = 'MER-303-APP-1'

      def initialize(payment_transaction)
        @payment_transaction = payment_transaction
        @transaction_amt = @payment_transaction.amount
        @ref_id          = @payment_transaction.transaction_id
      end

      def validate
        data = "MERCHANTID=#{MerchantId},APPID=#{AppId},REFERENCEID=#{@ref_id},TXNAMT=#{@transaction_amt}"

        uri     = URI.parse(NchlPayment::PAYMENT_VERIFICATION_URL)
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

        @payment_transaction.set_validation_request_sent_at
        response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
          http.request(request)
        end

        @payment_transaction.set_validation_response_received_at

        JSON.parse(response.body)
      end
    end
  end
end