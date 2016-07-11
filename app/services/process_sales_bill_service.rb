class ProcessSalesBillService
  include ApplicationHelper
  attr_accessor :error_message

  def initialize(params)
    @sales_settlement = params[:sales_settlement]
    @bank_account = params[:bank_account]
    bill_ids = params[:bill_ids]
    @bills = Bill.where(id: bill_ids)
    @error_message = ""
  end

  def process
    fy_code = get_fy_code

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
      voucher = Voucher.create!(date_bs: ad_to_bs_string(Time.now))
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
        # particular = process_accounts(client_ledger, voucher, true, amount_to_settle, _description)
        closing_balance = client_ledger.closing_blnc
        particular = Particular.create!(transaction_type: :dr, ledger_id: client_ledger.id, name: _description, voucher_id: voucher.id, amount: amount_to_settle, transaction_date: Time.now, particular_status: :pending)

        particulars << particular
        net_paid_amount += amount_to_settle

        # mark the bills as settled
        bill.balance_to_pay = 0
        bill.status = Bill.statuses[:settled]
        bill.settlement_approval_status = :pending_approval
        bill.save!

        description = "Bill No.:#{bill.fy_code}-#{bill.bill_number}   Amount: #{arabic_number(amount_to_settle)}   Date: #{bill.date_bs}"
        description_bills += description
        #  TODO(Subas) This is redundant in Voucher/create class
        cheque_entry.cheque_date = DateTime.now
        cheque_entry.status = ChequeEntry.statuses[:to_be_printed]
        cheque_entry.client_account_id = client_account.id
        cheque_entry.beneficiary_name = client_account.name.titleize
        cheque_entry.amount = amount_to_settle
        cheque_entry.save!
        particular.cheque_entries_on_payment << cheque_entry
        particular.save!
        #   TODO(Subas) This is redundant in Voucher/create class
        settlement = purchase_sales_settlement(voucher, ledger: client_account.ledger, particular: particular, client_account: client_account, description_bills: description)
        voucher.settlements << settlement if settlement.present?
      end
      # particular = process_accounts(bank_ledger, voucher, false, net_paid_amount, description
      closing_balance = bank_ledger.closing_blnc
      short_description = "Settlement by bank payment for settlement ID #{@sales_settlement.settlement_id}"
      Particular.create!(transaction_type: :cr, ledger_id: bank_ledger.id, name: short_description, voucher_id: voucher.id, amount: net_paid_amount,transaction_date: Time.now, particular_status: :pending, ledger_type: :has_bank)

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
    is_single_settlement = attrs[:is_single_settlement] || false
    receipt_amount = attrs[:receipt_amount] || 0
    client_group_leader_account = attrs[:client_group_leader_account]
    vendor_account = attrs[:vendor_account]

    settler_name = ""
    settlement = nil
    settlement_description ||= voucher.desc

    # incase of multiple settlement or default take the amount from particular
    if !is_single_settlement
      if voucher.receipt?
        receipt_amount += (particular.cr?) ? particular.amount : 0
      elsif voucher.payment?
        receipt_amount += (particular.dr?) ? particular.amount : 0
      end
    end

    # single settlement for all the transaction exist only for the group leader and vendor accounting
    if is_single_settlement
      if client_group_leader_account.present?
        settler_name = client_group_leader_account.name
      else
        settler_name = vendor_account.name
      end
    elsif client_account.present?
      settler_name = client_account.name
    else
      settler_name = ledger.name
    end


    if is_single_settlement
      settlement_type = Settlement.settlement_types[:payment]
      settlement_type = Settlement.settlement_types[:receipt] if voucher.receipt?
      settlement = Settlement.create(name: settler_name, amount: receipt_amount, description: settlement_description, date_bs: voucher.date_bs, settlement_type: settlement_type)
      settlement.client_account = client_group_leader_account
      settlement.vendor_account = vendor_account
    elsif voucher.receipt? && particular.cr? || voucher.payment? && particular.dr?
      settlement_type = Settlement.settlement_types[:payment]
      settlement_type = Settlement.settlement_types[:receipt] if voucher.receipt?
      settlement = Settlement.create(name: settler_name, amount: receipt_amount, description: settlement_description, date_bs: voucher.date_bs, settlement_type: settlement_type)
      settlement.client_account = client_account
    end

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