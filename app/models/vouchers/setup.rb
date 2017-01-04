class Vouchers::Setup < Vouchers::Base

  def voucher_and_relevant
    voucher_setup(@voucher_type, @client_account_id, @bill_ids, @bill_id, @clear_ledger)
  end

  def voucher_setup(voucher_type, client_account_id, bill_ids, bill_id, clear_ledger)
    is_payment_receipt = false
    default_ledger_id = nil
    # ledger_list_available will be filled conditionally (for wide array of cases)
    ledger_list_available = []

    client_account, bill, bills, amount, voucher_type, settlement_by_clearance, amount_to_pay_receive = set_bill_client(client_account_id, bill_ids, bill_id, voucher_type, clear_ledger)

    # do not create voucher if bills have pending deal cancel
    bills_have_pending_deal_cancel, bill_number_with_deal_cancel = bills_have_pending_deal_cancel(@bills)
    if bills_have_pending_deal_cancel
      @error_message = "Bill with bill number #{bill_number_with_deal_cancel} has pending deal cancel"
      return
    end

    voucher = get_new_voucher(voucher_type)

    bill_id_names = ""
    if voucher.is_payment_receipt?
      is_payment_receipt = true
      ledger_list_financial = BankAccount.by_branch_id.all.uniq.collect(&:ledger)
      default_bank_payment = BankAccount.by_branch_id.where(:default_for_payment => true).first
      default_bank_receive = BankAccount.by_branch_id.where(:default_for_receipt => true).first
      cash_ledger = Ledger.find_by(name: "Cash")

      ledger_list_financial << cash_ledger

      # default ledger selection for most of the cases
      if voucher.is_bank_related_receipt?
        default_ledger_id = default_bank_receive ? default_bank_receive.ledger.id : cash_ledger.id
      elsif voucher.is_bank_related_payment?
        default_ledger_id = default_bank_payment ? default_bank_payment.ledger.id : cash_ledger.id
      else
        default_ledger_id = cash_ledger.id
      end

      bill_id_names = bills.map { |a| "#{a.fy_code}-#{a.bill_number}" }.join(',')
      voucher.desc = "Settled for Bill No: #{bill_id_names}" if bills.size > 0
      voucher.desc = "Settled with ledger balance clearance" if clear_ledger
    end

    voucher.particulars = []
    # we need to prepopulate particulars
    if is_payment_receipt
      transaction_type = voucher.is_receipt? ? Particular.transaction_types[:dr] : Particular.transaction_types[:cr]
      voucher.particulars << Particular.new(ledger_id: default_ledger_id, amount: amount, transaction_type: transaction_type)
    end

    vendor_account_list = VendorAccount.all
    client_ledger_list = []

    # settlement by clearance only in case of payment to client
    # it is used to zero the account balance of the client.
    if settlement_by_clearance
      voucher.desc = "Settled for Bill No: #{bills.map { |a| "#{a.fy_code}-#{a.bill_number}" }.join(',')}" if bills.size > 0
      voucher.particulars << Particular.new(ledger_id: client_account.ledger.id, amount: amount, transaction_type: Particular.transaction_types[:cr])
      ledger_list_available << client_account.ledger
      clearance_ledger = Ledger.find_by!(name: "Clearing Account")
      voucher.particulars << Particular.new(ledger_id: clearance_ledger, amount: amount, transaction_type: Particular.transaction_types[:dr])
    else
      # for sales and purchase we need two particular one for debit and one for credit
      if client_account.present?
        voucher.particulars << Particular.new(ledger_id: client_account.ledger.id,
                                              amount: amount,
                                              bills_selection: bill_ids.join(','),
                                              selected_bill_names: bill_id_names )
        ledger_list_available << client_account.ledger
      end
      # a general particular for the voucher
      if client_account.nil?
        voucher.particulars << Particular.new
      end
    end
    return voucher, is_payment_receipt, ledger_list_financial, ledger_list_available, default_ledger_id, voucher_type, vendor_account_list, client_ledger_list
  end
end