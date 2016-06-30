class CreateSmsMessages < ActiveRecord::Migration
  def change
    create_table :sms_messages do |t|

      t.timestamps null: false
    end
  end
end
