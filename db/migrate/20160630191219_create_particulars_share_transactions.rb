class CreateParticularsShareTransactions < ActiveRecord::Migration
  def change
    create_table :particulars_share_transactions, id:false do |t|
      t.references :particular, index: true, foreign_key: true
      t.references :share_transaction, index: true, foreign_key: true
      t.integer :association_type
    end
  end
end
