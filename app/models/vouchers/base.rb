class Vouchers::Base
  include NumberFormatterModule
  include CustomDateModule
  include BillModule

  attr_reader :error_message

  def initialize(attrs = {})
    @client_account_id = attrs[:client_account_id]
    @bill_id = attrs[:bill_id]
    @voucher_type = attrs[:voucher_type]
    @error_message = nil
    @clear_ledger = attrs[:clear_ledger]
    @bill_ids = attrs[:bill_ids]
    @amount_margin_error = 0.01
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
    bill_ledger_adjustment = 0.0

    # get client account and bill if present
    client_account, bill = client_account_and_bill(client_account_id, bill_id)

    # different conditions that are available are
    #   1. clear ledger (clear ledger balance)
    #         clear_ledger to be true, client_account_id should be present
    #   2. bills present (settlement by selected bills)
    #   3. client account is present and voucher type is present
    #         process the bill types depending on voucher type
    #           voucher type receipt -> all purchase bills
    #           voucher type payment -> all sales bills
    #   4. specific bill
    #         process a specific bill

    if (clear_ledger || bill_ids.size > 0) && client_account.present?

      client_ledger = client_account.ledger
      ledger_balance = client_ledger.closing_balance

      if clear_ledger
        bills_receive = client_account.bills.requiring_receive
        bills_payment = client_account.bills.requiring_payment
      else
        bill_list = get_bills_from_ids(bill_ids)

        related_pending_bill_ids = client_account.get_all_related_bill_ids

        # make sure all id in bill_ids are in related_pending_bill_ids
        unless (bill_ids - related_pending_bill_ids).empty?
          # this condition should not be true
          raise NotImplementedError
        end

        bills_receive = bill_list.requiring_receive
        bills_payment = bill_list.requiring_payment
      end

      amount_to_receive = bills_receive.sum(:balance_to_pay)
      amount_to_pay = bills_payment.sum(:balance_to_pay)

      # negative if the company has to pay
      # positive if the client needs to pay
      amount_to_receive_or_pay = amount_to_receive - amount_to_pay
      #  if clear ledger is true clear the ledger balance
      #     payment voucher if the ledger balance is negative
      #     receipt voucher if the ledger balance is positive
      #     clear all bills

      # if bills are selected
      #   when purchase amount is greater than sales cases
      #     need to receive from bills and ledger has no advances
      #       receipt voucher
      #     need to receive from bills and ledger has some advances
      #       receipt voucher for remaining amount from client
      #     need to receive from bills and ledger has advances to cover up the bill amount
      #       use the balance and create general voucher, settle all bills


      if clear_ledger
        if ledger_balance > 0
          voucher_type = Voucher.voucher_types[:receipt]
          bills = [*bills_payment, *bills_receive]
        else
          voucher_type = Voucher.voucher_types[:payment]
          bills = [*bills_receive, *bills_payment]
        end
        amount = ledger_balance.abs
        bill_ledger_adjustment = amount_to_receive_or_pay.abs - amount
      else
        if amount_to_receive_or_pay + @amount_margin_error >= 0
          # ledger balance is positive implies client has something to pay

          if ledger_balance + @amount_margin_error >= 0
            voucher_type = Voucher.voucher_types[:receipt]
            bills = [*bills_payment, *bills_receive]

            # if ledger balance is equal to bills amount or greater than bills amount
            # client pays only the bills amount

            # eg. if >= 5000 ledger balance , 5000 amount to pay => get 5000
            if (ledger_balance - amount_to_receive_or_pay).abs <= @amount_margin_error || ledger_balance > amount_to_receive_or_pay
              amount = (amount_to_receive_or_pay).abs

              #  eg. 1000 ledger balance , 5000 amount to pay => get 1000
            else
              amount = ledger_balance
              bill_ledger_adjustment = amount_to_receive_or_pay - ledger_balance
            end
          else
            # this condition should not be true
            raise NotImplementedError
          end
        else
          # this case for condition when amount to pay is greater than amount to receive

          # ledger balance is positive implies client has due to pay
          # even if the current selection of bills imply we need to pay to client
          # we need to receive amount from client

          # this condition should not be true
          if ledger_balance + @amount_margin_error >= 0
            raise NotImplementedError

            #   eg -10000 ledger balance, -5000 amount to pay now => pay only 5000
          elsif ledger_balance <= amount_to_receive_or_pay
            voucher_type = Voucher.voucher_types[:payment]
            bills = [*bills_receive, *bills_payment]
            amount = (amount_to_receive_or_pay).abs

            #   eg -3000 ledger balance, -5000 amount to pay now => pay only 3000
          else
            voucher_type = Voucher.voucher_types[:payment]
            bills = [*bills_receive, *bills_payment]
            amount = ledger_balance.abs
            bill_ledger_adjustment = (ledger_balance - amount_to_receive_or_pay).abs
          end
        end
      end
    else
      # in case payment or receive is done
      case voucher_type
        when Voucher.voucher_types[:receipt]
          # check if the client account is present
          # and grab all the bills from which we can receive amount if bill is not present
          # else grab the amount to be paid from the bill

          # TODO(subas) Remove the condition where bill is not present
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
    return client_account, bill, bills, amount, voucher_type, settlement_by_clearance, bill_ledger_adjustment
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

  def bills_have_pending_deal_cancel(bill_list)
    res = false
    bill_number = nil
    bill_list ||= []
    bill_list.each do |bill|
      if bill.share_transactions.deal_cancel_pending.size > 0
        res = true
        bill_number = bill.bill_number
        break
      end
    end
    return res, bill_number
  end
end