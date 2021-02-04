class CreateEsewaPayments < ActiveRecord::Migration
  def change
    create_table :esewa_payments do |t|
      t.references :payment_transaction, index: true, foreign_key: true
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
