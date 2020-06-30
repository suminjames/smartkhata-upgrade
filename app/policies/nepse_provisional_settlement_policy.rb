class NepseProvisionalSettlementPolicy < NepseSettlementPolicy
  permit_custom_access :employee_and_above, nepse_provisional_settlements_path(0,0), [:transfer_requests]
end
