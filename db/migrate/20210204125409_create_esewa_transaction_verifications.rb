class CreateEsewaTransactionVerifications < ActiveRecord::Migration
  def change
    create_table :esewa_transaction_verifications do |t|
      t.references :esewa_payment, index: true, foreign_key: true
      t.string :request_sent_at
      t.string :response_received_at
      t.integer :status

      t.timestamps null: false
    end
  end
end
