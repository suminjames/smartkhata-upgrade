class AddRemarksToTransactionMessages < ActiveRecord::Migration
  def change
    add_column :transaction_messages, :remarks_email, :string
    add_column :transaction_messages, :remarks_sms, :string
  end
end
