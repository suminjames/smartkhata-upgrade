class ChequeEntries::Activity

  include ApplicationHelper

  attr_accessor :cheque_entry, :error_message, :selected_branch_id, :selected_fy_code

  def initialize(cheque_entry, current_tenant_full_name, selected_branch_id = nil, selected_fy_code = nil)
    @cheque_entry = cheque_entry
    @error_message = nil
    @bank = nil
    @name = nil
    @cheque_date = nil
    @current_tenant_full_name = current_tenant_full_name
    @margin_of_error_amount = 0.01
  end

  def process
    set_error('Please select the current fiscal year') and return unless valid_for_the_fiscal_year?
    return unless can_activity_be_done?
    set_error('Please select the correct branch') and return unless valid_branch?
    perform_action
  end

  def perform_action
    raise NotImplementedError
  end

  def can_activity_be_done?
    return false
  end

  def valid_branch?
    @cheque_entry.branch_id == @selected_branch_id
  end

  def valid_for_the_fiscal_year?
    @selected_fy_code == get_fy_code
  end

  def set_error(error_message)
    @error_message = error_message
  end

  def get_bank_name_and_date
    if @cheque_entry.additional_bank_id.present?
      @bank = Bank.find_by(id: @cheque_entry.additional_bank_id)
      @name = @current_tenant_full_name
    else
      @bank = @cheque_entry.bank_account.bank
      @name = @cheque_entry.beneficiary_name.present? ? @cheque_entry.beneficiary_name : "Internal Ledger"
    end
    @cheque_date = @cheque_entry.cheque_date.nil? ? DateTime.now : @cheque_entry.cheque_date
    return @bank, @name, @cheque_date
  end


end
