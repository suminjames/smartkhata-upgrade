class ProcessSalesBillService
  include ApplicationHelper
  attr_accessor :error_message

  def initialize(params)
    @sales_settlement = params[:sales_settlement]
    @bank_account = params[:bank_account]
    bill_ids = params[:bill_ids]
    @bills = Bill.where(id: bill_ids)
    @error_message = ""
    @date = params[:date] || Time.now
  end

  def process
    fy_code = get_fy_code(@date)

    # bank payment letter cant be created without bills and payment bank account
    if @bills.empty?
      @error_message = "Bill List is empty"
      return false
    elsif @bank_account.nil?
      @error_message = "No Bank Account is selected"
      return false
    elsif @sales_settlement.nil?
      @error_message = "Access denied"
      return false
    end

    bank_ledger = @bank_account.ledger

    particulars = []
    description = ""
    description_bills = ""
    net_paid_amount = 0.00
    ActiveRecord::Base.transaction do
      voucher = Voucher.create!(date: @date)
      voucher.pending!
      voucher.save!

      bills_have_pending_deal_cancel, bill_number_with_deal_cancel = bills_have_pending_deal_cancel(@bills)
      if bills_have_pending_deal_cancel
        @error_message = "Bill with bill number #{bill_number_with_deal_cancel} has pending deal cancel"
        raise ActiveRecord::Rollback
      end

      @bills.each do |bill|
        bank_account = @bank_account
        cheque_entry = ChequeEntry.unassigned.where(bank_account_id: bank_account.id).first
        if cheque_entry.blank?
          @error_message = "Insufficient Cheque Numbers"
          raise ActiveRecord::Rollback
        end
        client_account = bill.client_account
        client_ledger = client_account.ledger
        ledger_balance = client_ledger.closing_balance
        bill_amount = bill.balance_to_pay
        #
        # # dont pay the client more than he deserves.
        # # pay only if the ledger balance is negative
        # # for now we are not dealing with the positive amount
        # next if ledger_balance + margin_of_error_amount >= 0
        #
        # # when the ledger amount is greater or equal to bill
        # if (ledger_balance.abs - bill_amount) + margin_of_error_amount >= 0
        #   amount_to_settle = bill_amount
        # else
        #   amount_to_settle = ledger_balance.abs
        # end
        amount_to_settle = bill_amount

        voucher.bills_on_creation << bill
        _description = "Settlement by bank payment for Bill: #{bill.full_bill_number}"
        # particular = process_accounts(client_ledger, voucher, true, amount_to_settle, _description)
        closing_balance = client_ledger.closing_balance
        particular = Particular.create!(transaction_type: :dr, ledger_id: client_ledger.id, name: _description, voucher_id: voucher.id, amount: amount_to_settle, transaction_date: @date, particular_status: :pending, fy_code: fy_code)

        particulars << particular
        net_paid_amount += amount_to_settle

        # mark the bills as settled
        bill.balance_to_pay = 0
        bill.status = Bill.statuses[:settled]
        bill.settlement_approval_status = :pending_approval
        bill.save!

        description = "Bill No.:#{bill.fy_code}-#{bill.bill_number}   Amount: #{arabic_number(amount_to_settle)}   Date: #{bill.date_bs}  \n"
        description_bills += description
        #  TODO(Subas) This is redundant in Voucher/create class
        cheque_entry.cheque_date = DateTime.now
        cheque_entry.status = ChequeEntry.statuses[:pending_approval]
        cheque_entry.client_account_id = client_account.id
        cheque_entry.beneficiary_name = client_account.name.titleize
        cheque_entry.amount = amount_to_settle
        cheque_entry.save!
        particular.cheque_entries_on_payment << cheque_entry
        particular.save!

        settlement = purchase_sales_settlement(voucher, ledger: client_account.ledger, particular: particular, client_account: client_account, settlement_description: description)
        voucher.settlements << settlement if settlement.present?
      end
      # particular = process_accounts(bank_ledger, voucher, false, net_paid_amount, description
      closing_balance = bank_ledger.closing_balance
      short_description = "Settlement by bank payment for settlement ID #{@sales_settlement.settlement_id}"
      Particular.create!(transaction_type: :cr, ledger_id: bank_ledger.id, name: short_description, voucher_id: voucher.id, amount: net_paid_amount,transaction_date: @date, particular_status: :pending, ledger_type: :has_bank, fy_code: fy_code)

      if description_bills.blank?
        @error_message = "Error while processing, Client may have dues"
        raise ActiveRecord::Rollback
      end

      voucher.desc = description_bills
      voucher.is_payment_bank = true
      voucher.save!

    end

    return true if @error_message.blank?
  end



  def group_transaction_by_client(share_transactions)

  end

  def purchase_sales_settlement(voucher, attrs = {})
    ledger = attrs[:ledger]
    client_account = attrs[:client_account]
    settlement_description = attrs[:settlement_description]
    particular = attrs[:particular]
    settlement_amount =  particular.amount

    settlement = nil
    settlement_description ||= voucher.desc

    if client_account.present?
      settler_name = client_account.name
    else
      settler_name = ledger.name
    end

    settlement = Settlement.create(name: settler_name, amount: settlement_amount, description: settlement_description, date_bs: voucher.date_bs, settlement_type: Settlement.settlement_types[:payment], settlement_by_cheque_type: Settlement.settlement_by_cheque_types[:has_single_cheque])
    settlement.client_account = client_account

    settlement
  end


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