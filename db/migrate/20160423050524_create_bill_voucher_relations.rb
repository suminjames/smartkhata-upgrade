class CreateBillVoucherRelations < ActiveRecord::Migration
  def change
    create_table :bill_voucher_relations do |t|
      t.integer :relation_type
      t.belongs_to :bill, index: true, foreign_key: true
      t.belongs_to :voucher, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end