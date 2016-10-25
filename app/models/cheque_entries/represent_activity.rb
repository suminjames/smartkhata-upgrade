class ChequeEntries::RepresentActivity < ChequeEntries::Activity

  def can_activity_be_done?
    if @cheque_entry.additional_bank_id!= nil && !@cheque_entry.bounced?
      @error_message = "The Cheque cant be represented."
      return false
    end

    true
  end

  def perform_action
    voucher = @cheque_entry.vouchers.order(id: :asc).uniq.last

    ActiveRecord::Base.transaction do
      # create a new voucher and add the bill reference to it
      new_voucher = Voucher.create!(date_bs: ad_to_bs_string(Time.now))
      description = "Cheque number #{@cheque_entry.cheque_number} represented"
      voucher.particulars.each do |particular|
        reverse_accounts(particular, new_voucher, description)
      end

      @cheque_entry.represented!
      new_voucher.complete!
    end
  end
end