class CreateMasterSetupCommissionInfos < ActiveRecord::Migration
  def change
    create_table :master_setup_commission_infos do |t|
      t.date :start_date
      t.date :end_date
      t.string :start_date_bs
      t.string :end_date_bs
      t.float :nepse_commission_rate
      t.timestamps null: false
    end
  end
end
