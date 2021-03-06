class CreateMasterSetupCommissionDetails < ActiveRecord::Migration[4.2]
  def change
    create_table :master_setup_commission_details do |t|
      t.decimal :start_amount, precision: 15, scale: 4
      t.decimal :limit_amount, precision: 15, scale: 4
      t.float :commission_rate
      t.float :commission_amount
      t.references :master_setup_commission_info, index: {name: 'master_setup_commission_info_id'}, foreign_key: true
      t.timestamps null: false
    end
  end
end
