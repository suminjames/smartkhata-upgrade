class CreateEdisReports < ActiveRecord::Migration
  def change
    create_table :edis_reports do |t|
      t.bigint :settlement_id
      t.integer :sequence_number, default: 1
      t.integer :status, default: 0
      t.timestamps null: false
    end
  end
end
