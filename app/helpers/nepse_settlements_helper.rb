module NepseSettlementsHelper
  # Returns a dynamic path based on the provided parameters
  def sti_nepse_settlement_path(settlement_type = "nepse_settlement", nepse_settlement = nil, action = nil)
    send "#{format_sti(action, settlement_type, nepse_settlement)}_path", nepse_settlement
  end

  def format_sti(action, settlement_type, nepse_settlement)
    action || nepse_settlement ? "#{format_action(action)}#{settlement_type.underscore}" : settlement_type.underscore.pluralize.to_s
  end

  def format_action(action)
    action ? "#{action}_" : ""
  end
end
