class CreateMobileMessage < ActiveRecord::Migration
  def change
    create_table :mobile_message do |t|
      t.string :customer_code
      t.string :mobile_no
      t.string :transaction_date
      t.string :message_date
      t.string :bill_no
      t.string :message
      t.string :message_type
    end
  end
end
