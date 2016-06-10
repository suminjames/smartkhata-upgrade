class CreateTransactionMessages < ActiveRecord::Migration
  def change
    create_table :transaction_messages do |t|
      t.string :sms_message
      t.date :transaction_date
      t.integer :sms_status, default: 0
      t.integer :email_status, default: 0
      t.references :bill, index: true
      t.references :client_account, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
