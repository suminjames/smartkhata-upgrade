class CreateSystemPara < ActiveRecord::Migration[4.2]
  def change
    create_table :system_para do |t|
      t.string :nepse_purchase_ac
      t.string :nepse_sales_ac
      t.string :commission_purchase_ac
      t.string :commission_sales_ac
      t.string :name_transfer_rate
      t.string :nepse_capital_ac
      t.string :extra_commission_charge
      t.string :voucher_tag
      t.string :voucher_code
      t.string :name_transfer_ac
      t.string :cash_ac
      t.string :tds_ac
      t.string :sebo_ac
      t.string :demat_fee
      t.string :demat_fee_ac
      t.string :cds_fee_ac
      t.string :sebon_fee_ac
      t.string :sebon_regularity_fee_ac
    end
  end
end
