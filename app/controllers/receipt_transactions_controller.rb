class ReceiptTransactionsController < VisitorsController
  before_action :get_receipt_transaction, only: [:success, :failure]

  def initiate_payment
    all_bills = Bill.includes(:client_account).where(id: params[:bill_ids])

    @bills        = all_bills.decorate
    @total_amount = all_bills.sum(:net_amount).ceil(0)
    @bill_ids     = params[:bill_ids]

    @esewa_receipt_url = EsewaReceipt::PAYMENT_URL
    @nchl_receipt_url  = NchlReceipt::PAYMENT_URL
  end

  def success
    # this check is to make sure that the verification request is not sent again when the page is reloaded
    # as a previous payment_verification process would already have set the status of the transaction
    if @receipt_transaction.status.nil?
      @receipt_transaction.set_response_received_time
      if @receipt_transaction.receivable_type == "NchlReceipt"
        @verification_status = nchl_receipt_verification(@receipt_transaction)
      elsif @receipt_transaction.receivable_type == "EsewaReceipt"
        @verification_status = esewa_receipt_verification(@receipt_transaction.receivable)
      end
      create_voucher if @verification_status
    end
  end

  def failure
    @receipt_transaction.set_failure_response if @receipt_transaction.status.nil?
  end

  private

  def get_receipt_transaction
    transaction_id       = params[:TXNID] ? params[:TXNID] : params[:oid]
    @receipt_transaction = ReceiptTransaction.find_by(transaction_id: transaction_id)
  end

  def nchl_receipt_verification(receipt_transaction)
    ReceiptTransactions::Nchl::PaymentValidation.new(receipt_transaction).validate
  end

  def esewa_receipt_verification(esewa_receipt)
    # this is sent as a response from esewa and saved for future reference
    # refId is a unique payment reference code generated by eSewa
    # amt is the total payment amount

    esewa_receipt.set_response_ref_and_amt(params[:refId], params[:amt])

    ReceiptTransactions::Esewa::TransactionVerificationService.new(esewa_receipt).call
  end

  def create_voucher
    voucher_creation = ReceiptTransactions::Vouchers::VoucherCreationService.new(params, selected_branch_id, selected_fy_code, current_tenant).call
    if voucher_creation.process
      @voucher = voucher_creation.voucher
    else
      @voucher = voucher_creation.voucher
      # ledger list and is purchase sales is required for the extra section to show up for payment and receipt case
      # ledger list financial contains only bank ledgers and cash ledger
      # ledger list no banks contains all ledgers except banks (to avoid bank transfers using voucher)
      @ledger_list_financial   = voucher_creation.ledger_list_financial
      @ledger_list_available   = voucher_creation.ledger_list_available
      @vendor_account_list     = voucher_creation.vendor_account_list
      @client_ledger_list      = voucher_creation.client_ledger_list
      @is_payment_receipt      = voucher_creation.is_payment_receipt?(@voucher_type)
      @voucher_settlement_type = voucher_creation.voucher_settlement_type
      @group_leader_ledger_id  = voucher_creation.group_leader_ledger_id
      @vendor_account_id       = voucher_creation.vendor_account_id
    end
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.message
  end
end