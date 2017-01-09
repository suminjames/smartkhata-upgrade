class AddTenantToMasterSetupBrokerProfile < ActiveRecord::Migration
  def change
    add_reference :broker_profiles, :tenant, index: true
  end
end
