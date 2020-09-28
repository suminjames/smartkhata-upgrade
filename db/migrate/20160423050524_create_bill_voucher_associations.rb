class CreateBillVoucherAssociations < ActiveRecord::Migration[4.2]
  def change
    create_table :bill_voucher_associations do |t|
      t.integer :association_type
      t.belongs_to :bill, index: true, foreign_key: true
      t.belongs_to :voucher, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
