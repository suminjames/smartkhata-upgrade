class CreateEdisItems < ActiveRecord::Migration
  def change
    create_table :edis_items do |t|
      t.references :edis_report, index: true
      t.bigint :contract_number
      t.bigint :settlement_id
      t.date :settlement_date
      t.string :scrip
      t.string :boid
      t.string :client_code
      t.integer :quantity
      t.bigint :reference_id, index: true
      t.integer :creator_id
      t.integer :updater_id
      t.integer :reason_code
      t.integer :status, default: 0
      t.decimal :wacc, precision: 15, decimal: 2, default: 0.0

      t.timestamps null: false
    end
  end
end
