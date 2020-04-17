class CreateBuySettlement < ActiveRecord::Migration[4.2]
  def change
    create_table :buy_settlement do |t|
      t.string :transaction_no
      t.string :transaction_type
      t.string :transaction_date
      t.string :company_code
      t.string :quantity
      t.string :rate
      t.string :nepse_commission
      t.string :sebo_commission
      t.string :tds
      t.string :settlement_id
    end
  end
end
