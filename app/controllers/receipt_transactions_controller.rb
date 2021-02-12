class ReceiptTransactionsController < VisitorsController
  def initiate_payment
    all_bills = Bill.where(id: params[:bill_ids])

    @bills        = all_bills.decorate
    @total_amount = all_bills.sum(:net_amount).ceil(0)
    @bill_ids     = params[:bill_ids]

    @esewa_receipt_url = EsewaReceipt::PAYMENT_URL
    @nchl_receipt_url  = NchlReceipt::PAYMENT_URL
  end

  def success
    params[:TXNID] ? get_receipt_transaction(params[:TXNID]) : get_receipt_transaction(params[:oid])

    # this check is to make sure that the verification request is not sent again when the page is reloaded
    # as a previous payment_verification process would already have set the status of the transaction
    if @receipt_transaction.status.nil?
      @receipt_transaction.set_response_received_time

      if @receipt_transaction.receivable_type == "NchlPayment"
        # response = payment_validation @receipt_transaction
        # handle_validation_response @receipt_transaction, response
        @verification_status = nchl_receipt_verification(@receipt_transaction)
      elsif @receipt_transaction.receivable_type == "EsewaReceipt"
        @verification_status = esewa_receipt_verification(@receipt_transaction.receivable)
      end
    end
  end

  def failure
    params[:TXNID] ? get_receipt_transaction(params[:TXNID]) : get_receipt_transaction(params[:oid])
    @receipt_transaction.failure!
    @receipt_transaction.set_response_received_time if @receipt_transaction.status.nil?
  end

  private

  def get_receipt_transaction(transaction_id)
    @receipt_transaction = ReceiptTransaction.find_by(transaction_id: transaction_id)
  end

  def nchl_receipt_verification(receipt_transaction)
    ReceiptTransactions::Nchl::PaymentValidation.new(receipt_transaction).validate
  end

  def esewa_receipt_verification(esewa_receipt)
    # this is sent as a response from esewa and saved for future reference
    # refId is a unique payment reference code generated by eSewa
    # amt is the total payment amount

    esewa_receipt.set_response_ref(params[:refId])
    esewa_receipt.set_response_amount(params[:amt])

    ReceiptTransactions::Esewa::TransactionVerificationService.new(esewa_receipt).call
  end
end