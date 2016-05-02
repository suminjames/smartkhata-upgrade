class Vouchers::Base
  include NumberFormatterModule
  include CustomDateModule
  attr_reader :error_message

  def initialize(attrs = {})
    @client_account_id = attrs[:client_account_id]
    @bill_id = attrs[:bill_id]
    @voucher_type = attrs[:voucher_type]
    @error_message = nil
    @clear_ledger = attrs[:clear_ledger]
  end

  private

  def get_new_voucher(voucher_type)
    voucher = Voucher.new
    voucher.voucher_type = voucher_type
    voucher
  end

  def set_bill_client(client_account_id, bill_id, voucher_type, clear_ledger = false)
    # set default values to nil
    bills = []
    amount = 0.0

    # get client account and bill if present
    client_account, bill = client_account_and_bill(client_account_id, bill_id)

    # clear ledger functionality requires client account
    # check the bills requiring receive and payment
    # and set the voucher type accordingly
    if clear_ledger && client_account.present?
      bills_receive = client_account.bills.requiring_receive
      amount_to_receive = bills_receive.sum(:balance_to_pay)

      bills_payment = client_account.bills.requiring_payment
      amount_to_pay = bills_payment.sum(:balance_to_pay)

      # check whether its a payment or receive
      # note the order of bills depend on the condition above
      if amount_to_pay > amount_to_receive
        voucher_type = Voucher.voucher_types[:payment]
        bills = [*bills_receive, *bills_payment]
        amount = amount_to_pay - amount_to_receive
      else
        voucher_type = Voucher.voucher_types[:receive]
        bills = [*bills_payment,*bills_receive]
        amount = amount_to_receive - amount_to_pay
      end

    else
      case voucher_type
        when Voucher.voucher_types[:receive]
          # check if the client account is present
          # and grab all the bills from which we can receive amount if bill is not present
          # else grab the amount to be paid from the bill
          if client_account.present?
            unless bill.present?
              bills = client_account.bills.requiring_receive
              amount = bills.sum(:balance_to_pay)
            else
              bills = [bill]
              amount = bill.balance_to_pay
            end

            amount = amount.abs
          end

        when Voucher.voucher_types[:payment]
          if client_account.present?
            unless bill.present?
              bills = client_account.bills.requiring_payment
              amount = bills.sum(:balance_to_pay)
            else
              bills = [bill]
              amount = bill.balance_to_pay
            end
            amount = amount.abs
          end
      end
    end



    amount = amount.round(2)
    return client_account, bill, bills, amount, voucher_type
  end

  def client_account_and_bill(client_account_id, bill_id)
    # find the bills for the client
    # or client for the bill
    bill = nil
    client_account = nil
    if client_account_id.present?
      client_account = ClientAccount.find(client_account_id)
    elsif bill_id.present?
      bill = Bill.find(bill_id)
      client_account = bill.client_account
    end
    return client_account, bill
  end
end