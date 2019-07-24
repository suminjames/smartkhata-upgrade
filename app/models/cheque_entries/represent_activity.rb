class ChequeEntries::RepresentActivity < ChequeEntries::Activity

  # TODO(sarojk): Currently, cheque representation have been disabled. It needs reviving in the future.
  # The codes in the relevant areas (controller, models) depend on the following migration, which have been omitted. Re-generate as need arises.
  # class AddRepresentActivityToChequeEntries < ActiveRecord::Migration
  #   def change
  #     add_column :cheque_entries, :represent_date, :date
  #     add_column :cheque_entries, :represent_narration,  :text
  #   end
  # end

  def initialize(cheque_entry, represent_date_bs, represent_narration, current_tenant_full_name, selected_branch_id = nil, selected_fy_code = nil)
    super(cheque_entry, current_tenant_full_name, selected_branch_id, selected_fy_code)
    @cheque_entry.represent_date_bs = represent_date_bs
    @cheque_entry.represent_narration = represent_narration
  end

  def can_activity_be_done?

    if @cheque_entry.payment? || ( @cheque_entry.additional_bank_id!= nil && !@cheque_entry.bounced? )
      @error_message = "The cheque can not be represented."
      return false
    end

    if is_valid_bs_date? @cheque_entry.represent_date_bs
      @cheque_entry.represent_date = bs_to_ad(@cheque_entry.represent_date_bs)
    else
      @error_message = "The represent date is invalid."
      return false
    end

    if @cheque_entry.represent_date < @cheque_entry.cheque_date
      @cheque_entry.represent_date = bs_to_ad(@cheque_entry.represent_date_bs)
      @error_message = "The represent date can not be earlier than the cheque date."
      return false
    end

    true
  end

  def perform_action
    voucher = @cheque_entry.vouchers.order(id: :asc).uniq.last

    ActiveRecord::Base.transaction do
      # create a new voucher and add the bill reference to it
      new_voucher = Voucher.create!(date_bs: ad_to_bs_string(@cheque_entry.represent_date), date: @cheque_entry.represent_date)
      description = "Cheque number #{@cheque_entry.cheque_number} represented at #{ad_to_bs(@cheque_entry.represent_date)}. #{@cheque_entry.represent_narration}"
      voucher.particulars.each do |particular|
        reverse_accounts(particular, new_voucher, description)
      end

      @cheque_entry.represented!
      new_voucher.complete!
    end
  end
end