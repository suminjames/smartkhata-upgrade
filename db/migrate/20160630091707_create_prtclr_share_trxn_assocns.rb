class CreatePrtclrShareTrxnAssocns < ActiveRecord::Migration
  def change
    create_table :prtclr_share_trxn_assocns do |t|
      t.integer :association_type
      t.references :particular, index: true, foreign_key: true
      t.references :share_transaction, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
