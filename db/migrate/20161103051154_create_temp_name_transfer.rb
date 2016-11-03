class CreateTempNameTransfer < ActiveRecord::Migration
  def change
    create_table :temp_name_transfer do |t|
      t.integer :transaction_no, limit: 8
      t.integer :quantity
    end
  end
end
