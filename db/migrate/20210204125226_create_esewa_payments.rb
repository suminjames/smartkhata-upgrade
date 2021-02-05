class CreateEsewaPayments < ActiveRecord::Migration
  def change
    create_table :esewa_payments do |t|
      # t.references :payment_transaction, index: true, foreign_key: true

      t.decimal :amount #amt
      t.decimal :service_charge #psc
      t.decimal :delivery_charge #pdc
      t.decimal :tax_amount #txamt
      t.decimal :total_amount #tAmt
      t.string :pid #pid
      t.string :success_url #su
      t.string :failure_url #fu

      t.string :username
      t.string :response
      t.string :response_code
      t.integer :status
      t.string :request_sent_at
      t.string :response_received_at

      t.timestamps null: false
    end
  end
end
