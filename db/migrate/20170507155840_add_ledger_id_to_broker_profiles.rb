class AddLedgerIdToBrokerProfiles < ActiveRecord::Migration
  def change
    add_column :broker_profiles, :ledger_id, :integer
  end
end
