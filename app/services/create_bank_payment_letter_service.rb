class CreateBankPaymentLetterService
  include ApplicationHelper


  def initialize(params)
    @sales_settlement = params[:sales_settlement]
    bill_ids = params[:bill_ids]
    @bills = Bill.where(id: bill_ids)
  end

  def process
    fy_code = get_fy_code

    payment_bank_account = BankAccount.default_for_payment

    return false if @bills.empty? || payment_bank_account.nil?

    bank_ledger = payment_bank_account.ledger
    description = "Settlement by bank payment"

    voucher = Voucher.create!(date_bs: ad_to_bs_string(Time.now))
    voucher.desc = description
    voucher.complete!
    voucher.save!

    net_paid_amount = 0.00
    @bills.each do |bill|
      client_account = bill.client_account
      client_ledger = client_account.ledger
      ledger_balance = client_ledger.closing_blnc

      # dont pay the client more than he deserves.
      if ledger_balance - bill.balance_to_pay + margin_of_error_amount > 0
        
      end

      voucher.bills_on_creation << bill
      _description = "Settlement by bank payment for Bill: #{bill.full_bill_number}"
      process_accounts(client_ledger, voucher, true, bill.balance_to_pay, _description)
      net_paid_amount += bill.balance_to_pay
    end
    process_accounts(bank_ledger, voucher, false, net_paid_amount, description)
  end

  def group_transaction_by_client(share_transactions)

  end


end
