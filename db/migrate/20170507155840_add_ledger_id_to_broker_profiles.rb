class AddLedgerIdToBrokerProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :broker_profiles, :ledger_id, :integer
  end
end
