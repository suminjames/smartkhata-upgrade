class CreateNepseProvisionalSettlements < ActiveRecord::Migration[4.2]
  def change
    create_table :nepse_provisional_settlements do |t|
      t.bigint :settlement_id
      t.integer :status

      t.timestamps null: false
    end
  end
end
