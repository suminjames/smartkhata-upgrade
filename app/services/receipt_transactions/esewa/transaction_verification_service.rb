require 'net/http'

module ReceiptTransactions
  module Esewa
    class TransactionVerificationService

      def initialize(esewa_receipt)
        @esewa_receipt = esewa_receipt
        @receipt_transaction = @esewa_receipt.receipt_transaction
      end

      def call
        parameters = get_params

        uri = URI.parse(get_url)

        @receipt_transaction.set_validation_request_sent_at
        response = Net::HTTP.post_form(uri, parameters)
        @receipt_transaction.set_validation_response_received_at

        # "<response>\n" + "<response_code>\n" + "Success\n" + "</response_code>\n" + "</response>\n" - success response from esewa

        hashed_response = Hash.from_xml(response.body.gsub("\n", ""))
        handle_response(hashed_response['response']['response_code']=='Success')
      end

      private
      def get_url
        EsewaReceipt::PAYMENT_VERIFICATION_URL
      end

      def handle_response(success)
        if success
          @receipt_transaction.success!
        else
          @receipt_transaction.fraudulent!
          false
        end
      end

      def get_params
        {
            amt: @receipt_transaction.amount,
            rid: @esewa_receipt.response_ref,
            pid: @esewa_receipt.id,
            scd: Rails.application.secrets.esewa_security_code
        }
      end

    end
  end
end