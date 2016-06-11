class AddedAttributesToTransactionMessage < ActiveRecord::Migration
  def change
    add_column :transaction_messages, :deleted_at, :date
    add_column :transaction_messages, :sent_sms_count, :integer
    add_column :transaction_messages, :sent_email_count, :integer
  end
end
