class CreateNchlReceipts < ActiveRecord::Migration
  def change
    create_table :nchl_receipts do |t|
      t.string :reference_id
      t.text :remarks
      t.text :particular
      t.text :token

      t.timestamps null: false
    end
  end
end
