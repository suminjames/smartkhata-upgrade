class CreateSmsMessages < ActiveRecord::Migration[4.2]
  def change
    create_table :sms_messages do |t|

      t.timestamps null: false
    end
  end
end
