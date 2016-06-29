class AddDefaultValueToTransactionMessage < ActiveRecord::Migration
  def change
    change_column_default(:transaction_messages, :sent_sms_count, 0)
    change_column_default(:transaction_messages, :sent_email_count, 0)
  end
end
