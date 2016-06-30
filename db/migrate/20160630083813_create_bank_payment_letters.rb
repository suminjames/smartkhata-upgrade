class CreateBankPaymentLetters < ActiveRecord::Migration
  def change
    create_table :bank_payment_letters do |t|
      t.decimal :settlement_amount, precision: 15, scale: 4, default: 0

      t.integer :fy_code
      t.integer :creator_id
      t.integer :updater_id
      t.references :bank_account, index: true
      t.references :sales_settlement, index: true, foreign_key: true
      t.references :branch, index: true, foreign_key: true
      t.references :voucher, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
