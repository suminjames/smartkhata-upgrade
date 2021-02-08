require 'net/http'
require 'nokogiri'

module PaymentTransaction
  module Esewa
    class TransactionVerificationService

      def initialize(verification)
        @verification = verification
      end

      def call
        payment = @verification.esewa_payment
        parameters = get_params(payment)

        uri = URI.parse(get_url)

        response = NET::HTTP.post_form(uri, parameters)

        response.include?('success') ? true : false

      end

      private
      def get_url
        EsewaPayment::PAYMENT_VERIFICATION_URL
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