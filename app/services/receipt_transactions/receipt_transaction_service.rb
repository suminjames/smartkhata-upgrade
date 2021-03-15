module ReceiptTransactions
  class ReceiptTransactionService
    def initialize(payment, transaction_id, transaction_date, amount)
      @payment = payment
      @transaction_id = transaction_id
      @transaction_date = transaction_date
      @amount = amount
    end
    
    def call
      receipt_transaction = @payment.build_receipt_transaction(transaction_id:  @transaction_id,
                                                           transaction_date: @transaction_date,
                                                           request_sent_at:  Time.now,
                                                           amount:           @amount,
                                                           bill_ids:         @payment.bill_ids)
      unless receipt_transaction.save
        raise ActiveRecord::RecordInvalid.new(@payment)
      end
    end
  end
end