require 'net/http'
require 'nokogiri'

module PaymentTransactions
  module Esewa
    class TransactionVerificationService

      def initialize(esewa_payment)
        @esewa_payment = esewa_payment
        @payment_transaction = @esewa_payment.payment_transaction
      end

      def call
        parameters = get_params

        uri = URI.parse(get_url)
        
        @payment_transaction.set_validation_request_sent_at
        response = Net::HTTP.post_form(uri, parameters)
        @payment_transaction.set_validation_response_received_at

        # "<response>\n" + "<response_code>\n" + "Success\n" + "</response_code>\n" + "</response>\n" - success response from esewa

        handle_response(response.body.include?('Success'))
      end

      private
      def get_url
        EsewaPayment::PAYMENT_VERIFICATION_URL
      end

      def handle_response(res)
        if res
          @payment_transaction.success!
        else
          @payment_transaction.fail!
          false
        end
      end

      def get_params
        {
            amt: @payment_transaction.amount,
            rid: @esewa_payment.response_ref,
            pid: @esewa_payment.id,
            scd: Rails.application.secrets.esewa_security_code
        }
      end

    end
  end
end