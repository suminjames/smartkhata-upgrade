class MasterSetup::BrokerProfile < BrokerProfile
  default_scope { is_self_broker }
end
