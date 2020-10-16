class Print::PrintMultipleSettlements < Print::PrintSettlement
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper

  def initialize(settlements, current_tenant)
    super
    @current_tenant = current_tenant
    @settlements = settlements
  end

  def call_multiple
    @settlements.each_with_index do |settlement, index|
      call(settlement)
      start_new_page if index != @settlements.length - 1
    end
  end
end
