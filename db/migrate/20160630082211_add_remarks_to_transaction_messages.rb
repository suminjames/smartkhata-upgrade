class AddRemarksToTransactionMessages < ActiveRecord::Migration[4.2]
  def change
    add_column :transaction_messages, :remarks_email, :string
    add_column :transaction_messages, :remarks_sms, :string
  end
end
