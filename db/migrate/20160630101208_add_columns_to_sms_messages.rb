class AddColumnsToSmsMessages < ActiveRecord::Migration[4.2]
  def change
    add_column :sms_messages, :phone, :string
    add_column :sms_messages, :phone_type, :integer, default: 0
    add_column :sms_messages, :sms_type, :integer, default: 0
    add_column :sms_messages, :credit_used, :integer
    add_column :sms_messages, :remarks, :integer

    add_reference :sms_messages, :transaction_message, index: true, foreign_key: true

    add_column :sms_messages, :creator_id, :integer
    add_column :sms_messages, :updater_id, :integer
    add_column :sms_messages, :fy_code, :integer
    add_column :sms_messages, :branch_id, :integer

    add_index :sms_messages, :creator_id
    add_index :sms_messages, :updater_id
    add_index :sms_messages, :fy_code
    add_index :sms_messages, :branch_id
  end
end
