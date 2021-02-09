require 'net/http'
require 'nokogiri'

module PaymentTransactions
  module Esewa
    class TransactionVerificationService

      def initialize(verification)
        @verification = verification
      end

      def call
        payment = @verification.esewa_payment
        parameters = get_params(payment)

        @verification.set_request_sent_time
        uri = URI.parse(get_url)

        response = Net::HTTP.post_form(uri, parameters)
        @verification.set_response_received_time

        response.body.include?('success') ? handle_response(true) : handle_response(false)
      end

      private
      def get_url
        EsewaPayment::PAYMENT_VERIFICATION_URL
      end

      def handle_response(res)
        if res
          @verification.success!
        else
          @verification.fail!
        end
      end

      def get_params(payment)
        {
            amt: payment.total_amount,
            rid: payment.response_ref,
            pid: payment.id,
            scd: Rails.application.secrets.esewa_security_code
        }
      end

    end
  end
end