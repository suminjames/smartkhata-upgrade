class AddedAttributesToTransactionMessage < ActiveRecord::Migration
  def change
    add_column :transaction_messages, :deleted_at, :date
    add_column :transaction_messages, :sent_sms_count, :integer, default: 0
    add_column :transaction_messages, :sent_email_count, :integer, default: 0
  end
end
