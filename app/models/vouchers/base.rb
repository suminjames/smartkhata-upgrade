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
    @bill_ids = attrs[:bill_ids]
  end

  private

  def get_new_voucher(voucher_type)
    voucher = Voucher.new
    voucher.voucher_type = voucher_type
    voucher
  end

  def set_bill_client(client_account_id, bill_ids, bill_id, voucher_type, clear_ledger = false)
    # set default values to nil
    bill_ids ||= []
    amount = 0.0
    bills = []
    settlement_by_clearance = false

    # get client account and bill if present
    client_account, bill = client_account_and_bill(client_account_id, bill_id)

    # different conditions that are available are
    #   1. clear ledger (clear ledger balance)
    #         clear_ledger to be true, client_account_id should be present
    #   2. bills present (settlement by selected bills)
    #   3. client account is present and voucher type is present
    #         process the bill types depending on voucher type
    #           voucher type receive -> all purchase bills
    #           voucher type payment -> all sales bills
    #   4. specific bill
    #         process a specific bill

    if ( clear_ledger || bill_ids.size > 0 ) && client_account.present?

      client_ledger = client_account.ledger
      ledger_balance = client_ledger.closing_blnc

      if clear_ledger
        bills_receive = client_account.bills.requiring_receive
        bills_payment = client_account.bills.requiring_payment
      else
        bill_list = get_bills_from_ids(bill_ids)
        bills_receive = bill_list.requiring_receive
        bills_payment = bill_list.requiring_payment
      end

      amount_to_receive = bills_receive.sum(:balance_to_pay)
      amount_to_pay = bills_payment.sum(:balance_to_pay)

      # negative if the company has to pay
      # positive if the client needs to pay
      amount_to_pay_receive = amount_to_receive - amount_to_pay


      # do not pay the client yet until he asks for it
      if ledger_balance + amount_to_pay_receive > 0
        voucher_type = Voucher.voucher_types[:receive]
        bills = [*bills_payment,*bills_receive]
        # amount = amount_to_receive - amount_to_pay

        if ledger_balance <= 0
          amount = amount_to_pay_receive + ledger_balance
        else
          amount = (amount_to_pay_receive).abs
        end

      else
        if ledger_balance.abs > amount_to_pay_receive.abs
          voucher_type = Voucher.voucher_types[:journal]
          amount = amount_to_pay_receive.abs
          settlement_by_clearance = true
        else
          voucher_type = Voucher.voucher_types[:payment]
          amount = (ledger_balance - amount_to_pay_receive).abs
        end

        bills = [*bills_receive, *bills_payment]
      end


    # might be required later
    # TODO(SUBAS) Clean it up before final release


    # else
    #   case voucher_type
    #     when Voucher.voucher_types[:receive]
    #       # check if the client account is present
    #       # and grab all the bills from which we can receive amount if bill is not present
    #       # else grab the amount to be paid from the bill
    #       if client_account.present?
    #         unless bill.present?
    #           bills = client_account.bills.requiring_receive
    #           amount = bills.sum(:balance_to_pay)
    #         else
    #           bills = [bill]
    #           amount = bill.balance_to_pay
    #         end
    #
    #         amount = amount.abs
    #       end
    #
    #     when Voucher.voucher_types[:payment]
    #       if client_account.present?
    #         unless bill.present?
    #           bills = client_account.bills.requiring_payment
    #           amount = bills.sum(:balance_to_pay)
    #         else
    #           bills = [bill]
    #           amount = bill.balance_to_pay
    #         end
    #         amount = amount.abs
    #       end
    #   end
    end

    amount = amount.round(2)
    return client_account, bill, bills, amount, voucher_type, settlement_by_clearance
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

  def get_bills_from_ids(bill_ids)
    return Bill.where(id: bill_ids)
  end
end