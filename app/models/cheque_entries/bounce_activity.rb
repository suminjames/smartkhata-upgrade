class ChequeEntries::BounceActivity < ChequeEntries::RejectionActivity

  def initialize(cheque_entry, bounce_date_bs, bounce_narration, current_tenant_full_name, selected_branch_id = nil, selected_fy_code = nil, current_user)
    super(cheque_entry, current_tenant_full_name, selected_branch_id, selected_fy_code, current_user)
    @cheque_entry.bounce_date_bs = bounce_date_bs
    @cheque_entry.bounce_narration = bounce_narration
    @selected_branch_id = selected_branch_id
    @selected_fy_code = selected_fy_code
    @current_user = current_user
  end

  def valid_for_the_fiscal_year?
    @selected_fy_code == get_fy_code(bs_to_ad @cheque_entry.bounce_date_bs)
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
    # particular_ids = ChequeEntryParticularAssociation.where(cheque_entry_id: @cheque_entry).pluck(:particular_id)
    # voucher = Particular.unscoped.where(id: particular_ids).first.try(:voucher)
    if voucher.cheque_entries.uniq.count != 1
      bounce_for_multiple_associated_cheques voucher
    else
      bounce_for_single_voucher voucher
    end
  end

  def bounce_for_single_voucher voucher
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
      new_voucher = Voucher.create!(date: @cheque_entry.bounce_date, branch_id: @selected_branch_id, current_user_id: @current_user.id)
      new_voucher.bills_on_settlement = processed_bills

      description = "Cheque number #{@cheque_entry.cheque_number} bounced at #{ad_to_bs(@cheque_entry.bounce_date)}. #{@cheque_entry.bounce_narration}."
      voucher.particulars.each do |particular|
        reverse_accounts(particular, new_voucher, description, 0.0, nil, @current_user.id)
      end

      if new_voucher.particulars.size != voucher.particulars.size
        set_error('The cheque can not be bounced...Please contact technical support.')
        raise ActiveRecord::Rollback
      end

      @cheque_entry.bounced!
      new_voucher.complete!
      voucher.reversed!
    end
  end

  def bounce_for_multiple_associated_cheques voucher
    # bounce is for received cheques
    # client particular is cr
    cr_particulars = @cheque_entry.particulars.cr
    bank_particulars = @cheque_entry.associated_bank_particulars
    # assumed that a receipt cheque is attached to a single bank
    raise SmartKhataError  if bank_particulars.count != 1
    dr_particular = bank_particulars.first

    cheque_amount = @cheque_entry.amount
    particulars_for_reverse_entry = [dr_particular]
    processed_bills = []

    unless cr_particulars.count == 1
      cr_particulars = cr_particulars.select{|x| x.amount == cheque_amount}
    end

    # case when single payee && multiple cheque
    if cr_particulars.count == 1 
      # reverse the cheque amount only
      particular = cr_particulars.first
      particular.amount = cheque_amount
      particulars_for_reverse_entry << particular

      @bills = voucher.bills.purchase.order(id: :desc)
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
    else
      set_error('The cheque can not be bounced...Please contact technical support.') and return
    end

    ActiveRecord::Base.transaction do
      processed_bills.each(&:save)

      # create a new voucher and add the bill reference to it
      new_voucher = Voucher.create!(date: @cheque_entry.bounce_date, branch_id: @selected_branch_id, current_user_id: @current_user.id)
      new_voucher.bills_on_settlement = processed_bills

      description = "Cheque number #{@cheque_entry.cheque_number} bounced at #{ad_to_bs(@cheque_entry.bounce_date)}. #{@cheque_entry.bounce_narration}."
      particulars_for_reverse_entry.each do |particular|
        reverse_accounts(particular, new_voucher, description, 0.0, cheque_entry, @current_user.id)
      end

      if new_voucher.particulars.size != particulars_for_reverse_entry.size
        set_error('The cheque can not be bounced...Please contact technical support.')
        raise ActiveRecord::Rollback
      end

      @cheque_entry.bounced!
      new_voucher.complete!
      voucher.reversed!
    end
    # set_error('The cheque can not be bounced...Please contact technical support.')
  end

end