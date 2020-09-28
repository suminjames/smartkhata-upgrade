class AddParticularIdToLedger < ActiveRecord::Migration
  def change
    add_column :ledger, :particular_id, :integer
  end
end
