class CreateMobileMessage < ActiveRecord::Migration
  def change
    create_table :mobile_message do |t|
      t.string :customer_code
      t.string :mobile_no
      t.date :transaction_date
      t.date :message_date
      t.string :bill_no
      t.string :message
      t.string :message_type
    end
  end
end
