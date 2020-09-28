class CreateTempNameTransfer < ActiveRecord::Migration
  def change
    create_table :temp_name_transfer do |t|
      t.string :transaction_no
      t.string :quantity
    end
  end
end
