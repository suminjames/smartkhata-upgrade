class CreateTempNameTransfer < ActiveRecord::Migration[4.2]
  def change
    create_table :temp_name_transfer do |t|
      t.string :transaction_no
      t.string :quantity
    end
  end
end
