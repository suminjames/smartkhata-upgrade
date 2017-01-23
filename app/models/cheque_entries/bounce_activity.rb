class ChequeEntries::BounceActivity < ChequeEntries::RejectionActivity

  def initialize(cheque_entry, bounce_date_bs, bounce_narration, current_tenant_full_name)
    super(cheque_entry, current_tenant_full_name)
    @cheque_entry.bounce_date_bs = bounce_date_bs
    @cheque_entry.bounce_narration = bounce_narration
  end

  def can_activity_be_done?
    if @cheque_entry.payment? || ( @cheque_entry.additional_bank_id!= nil && @cheque_entry.bounced? )
      @error_message = "The cheque can not be bounced."
      return false
    end

    if is_valid_bs_date? @cheque_entry.bounce_date_bs
      @cheque_entry.bounce_date = bs_to_ad(@cheque_entry.bounce_date_bs)
    else
      @error_message = "The bounce date is invalid."
      return false
    end

    if @cheque_entry.bounce_date < @cheque_entry.cheque_date
      @cheque_entry.bounce_date = bs_to_ad(@cheque_entry.bounce_date_bs)
      @error_message = "The bounce date can not be earlier than the cheque date."
      return false
    end

    true
  end

  def perform_action
    voucher = @cheque_entry.vouchers.uniq.first
    set_error('The cheque can not be bounced...Please contact technical support.') and return if voucher.cheque_entries.uniq.count != 1


    @bills = voucher.bills.purchase.order(id: :desc)
    cheque_amount = @cheque_entry.amount
    processed_bills = []

    @bills.each do |bill|
      if cheque_amount + @margin_of_error_amount < bill.net_amount
        bill.balance_to_pay = cheque_amount
        bill.status = Bill.statuses[:partial]
        processed_bills << bill
        break
      else
        bill.balance_to_pay = bill.net_amount
        bill.status = Bill.statuses[:pending]
        cheque_amount -= bill.net_amount
        processed_bills << bill
      end
    end

    ActiveRecord::Base.transaction do
      processed_bills.each(&:save)
      # create a new voucher and add the bill reference to it
      new_voucher = Voucher.create!(date_bs: ad_to_bs_string(@cheque_entry.bounce_date), date: @cheque_entry.bounce_date)
      new_voucher.bills_on_settlement = processed_bills

      description = "Cheque number #{@cheque_entry.cheque_number} bounced at #{ad_to_bs(@cheque_entry.bounce_date)}. #{@cheque_entry.bounce_narration}"
      voucher.particulars.each do |particular|
        reverse_accounts(particular, new_voucher, description)
      end

      @cheque_entry.bounced!
      new_voucher.complete!
      voucher.reversed!
    end
  end
end