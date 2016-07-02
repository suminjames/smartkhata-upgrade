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
    particulars = []
    net_paid_amount = 0.00
    ActiveRecord::Base.transaction do
      voucher = Voucher.create!(date_bs: ad_to_bs_string(Time.now))
      voucher.desc = description
      voucher.complete!
      voucher.save!
      @bills.each do |bill|
        client_account = bill.client_account
        client_ledger = client_account.ledger
        ledger_balance = client_ledger.closing_blnc
        bill_amount = bill.balance_to_pay
        # dont pay the client more than he deserves.
        # pay only if the ledger balance is negative
        # for now we are not dealing with the positive amount
        next if ledger_balance + margin_of_error_amount >= 0

        # when the ledger amount is greater or equal to bill
        if (ledger_balance.abs - bill_amount) + margin_of_error_amount >= 0
          amount_to_settle = bill_amount
        else
          amount_to_settle = ledger_balance.abs
        end

        voucher.bills_on_creation << bill
        _description = "Settlement by bank payment for Bill: #{bill.full_bill_number}"
        particular = process_accounts(client_ledger, voucher, true, amount_to_settle, _description)
        particulars << particular
        net_paid_amount += amount_to_settle
      end
      particular = process_accounts(bank_ledger, voucher, false, net_paid_amount, description)
    end
    return particulars, net_paid_amount
  end

  def group_transaction_by_client(share_transactions)

  end


end
