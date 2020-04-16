class AddParticularIdToLedger < ActiveRecord::Migration[4.2]
  def change
    add_column :ledger, :particular_id, :integer
  end
end
