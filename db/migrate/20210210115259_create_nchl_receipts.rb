class CreateNchlReceipts < ActiveRecord::Migration[4.2]
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
