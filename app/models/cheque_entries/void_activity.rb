class ChequeEntries::VoidActivity < ChequeEntries::RejectionActivity

  def can_activity_be_done?
    # only approved cheque can be made void
    unless @cheque_entry.approved? && @cheque_entry.payment?
      @error_message = "The Cheque cant be made Void."
      return false
    end

    true
  end

  def perform_action
    voucher = @cheque_entry.vouchers.uniq.first

    # currently we dont pay by more than one cheque manually
    # only case where such happens is during sales bill payment
    is_multi_cheque_voucher = false
    is_multi_cheque_voucher = true if voucher.cheque_entries.uniq.count != 1


    unless is_multi_cheque_voucher
      @bills = voucher.bills.sales.order(id: :desc)
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
        new_voucher = Voucher.create!(date_bs: ad_to_bs_string(Time.now))
        new_voucher.bills_on_settlement = processed_bills

        description = "Cheque number #{@cheque_entry.cheque_number} void"

        voucher.particulars.each do |particular|
          reverse_accounts(particular, new_voucher, description)
        end


        @cheque_entry.void!
        new_voucher.complete!
        # since it is a single cheque voucher it can be reversed
        voucher.reversed!
      end
    else
      particular = @cheque_entry.particulars.first
      client_ledger = particular.ledger
      bank_ledger = @cheque_entry.bank_account.ledger
      client_branch_id = particular.branch_id
      bank_branch_id = @cheque_entry.branch_id

      # make sure the particular is not a bank ledger particular
      set_error('The Cheque cant be made Void. Please contact technical support') and return if client_ledger.bank_account_id.present?

      @bills = particular.bills.sales.order(id: :desc).select{|b| b.client_account_id == client_ledger.client_account_id }
      cheque_amount = @cheque_entry.amount
      processed_bills = []

      @bills.each do |bill|
        if cheque_amount + margin_of_error_amount < bill.net_amount
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
        new_voucher = Voucher.create!(date_bs: ad_to_bs_string(Time.now))
        new_voucher.bills_on_settlement = processed_bills

        description = "Cheque number #{@cheque_entry.cheque_number} void"

        process_accounts(client_ledger, new_voucher, false, @cheque_entry.amount, description, client_branch_id, Time.now)
        bank_particular = process_accounts(bank_ledger, new_voucher, true, @cheque_entry.amount, description, bank_branch_id, Time.now)
        bank_particular.cheque_entries_on_receipt << @cheque_entry


        @cheque_entry.void!
        new_voucher.complete!
      end
    end
  end
end