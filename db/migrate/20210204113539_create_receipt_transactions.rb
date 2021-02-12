class CreateReceiptTransactions < ActiveRecord::Migration
  def change
    create_table :receipt_transactions do |t|
      t.decimal :amount
      t.integer :status
      t.string :transaction_id
      t.datetime :request_sent_at
      t.datetime :response_received_at
      t.datetime :validation_request_sent_at
      t.datetime :validation_response_received_at
      t.integer :validation_response_code
      t.date :transaction_date
      t.belongs_to :receivable, polymorphic: true
      t.timestamps null: false
    end
  end
end