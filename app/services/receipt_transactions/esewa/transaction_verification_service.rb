require 'net/http'

module ReceiptTransactions
  module Esewa
    class TransactionVerificationService

      def initialize(receipt_transaction)
        @receipt_transaction = receipt_transaction
        @esewa_receipt = @receipt_transaction.receivable
      end

      def call
        parameters = get_params

        uri = URI.parse(get_url)

        @receipt_transaction.set_validation_request_sent_at
        response = Net::HTTP.post_form(uri, parameters)
        @receipt_transaction.set_validation_response(response.code)

        handle_response(response)
      end

      private
      def get_url
        EsewaReceipt::PAYMENT_VERIFICATION_URL
      end

      def process_response_body(success)
        if success
          @receipt_transaction.success!
        else
          @receipt_transaction.fraudulent!
          false
        end
      end

      def handle_response(response)
        if response.code=='200' && !response.body.empty?
          # "<response>\n" + "<response_code>\n" + "Success\n" + "</response_code>\n" + "</response>\n" - success response from esewa
          hashed_response = Hash.from_xml(response.body.gsub("\n", ""))
          process_response_body(hashed_response.dig('response', 'response_code')=='Success')
        else
          @receipt_transaction.unprocessed_verification!
        end
      end

      def get_params
        {
            amt: @receipt_transaction.amount,
            rid: @esewa_receipt.response_ref,
            pid: @receipt_transaction.transaction_id,
            scd: Rails.application.secrets.esewa_security_code
        }
      end

    end
  end
end