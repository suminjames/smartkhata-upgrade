class CreatePaymentTransactions < ActiveRecord::Migration
  def change
    create_table :payment_transactions do |t|
      t.decimal :amount
      t.integer :status
      t.integer :attempts
      t.integer :kind

      t.timestamps null: false
    end
  end
end