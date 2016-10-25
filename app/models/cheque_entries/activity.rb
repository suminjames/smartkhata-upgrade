class ChequeEntries::Activity
  include FiscalYearModule

  attr_accessor :cheque_entry, :error_message

  def initialize(cheque_entry)
    @cheque_entry = cheque_entry
    @error_message = nil
  end

  def process
    set_error('Please select the current fiscal year') and return unless valid_for_the_fiscal_year?
    return unless can_activity_be_done?
    perform_action
  end

  def perform_action
    raise NotImplementedError
  end

  def can_activity_be_done?
    return false
  end

  def valid_for_the_fiscal_year?
    UserSession.selected_fy_code == get_fy_code
  end

  def set_error(error_message)
    @error_message = error_message
  end
end