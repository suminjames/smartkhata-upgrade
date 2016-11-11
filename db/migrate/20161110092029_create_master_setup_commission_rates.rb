class CreateMasterSetupCommissionRates < ActiveRecord::Migration
  def change
    create_table :master_setup_commission_rates do |t|
      t.date :date_from
      t.date :date_to
      t.decimal :amount_gt
      t.decimal :amount_lt_eq
      t.decimal :rate
      t.boolean :is_flat_rate
      t.string :remarks

      t.timestamps null: false
    end
  end
end
