class CreateShareTransactions < ActiveRecord::Migration
  def change
    create_table :share_transactions do |t|
  		t.decimal :contract_no, precision: 18, scale:0
    	t.integer :buyer
    	t.integer :seller
    	t.integer :quantity
    	t.decimal :rate , precision: 10, scale: 3, default: 0
    	t.decimal :share_amount , precision: 15, scale: 3, default: 0
    	t.decimal :sebo , precision: 15, scale: 3, default: 0
    	t.decimal :commission , precision: 15, scale: 3, default: 0
    	t.decimal :dp_fee, precision: 15, scale: 3, default: 0
    	t.decimal :cgt , precision: 15, scale: 3, default: 0
    	t.decimal :net_amount , precision: 15, scale: 3, default: 0
    	t.decimal :bank_deposit , precision: 15, scale: 3, default: 0
    	t.integer :transaction_type 
    	t.date :date
  		t.timestamps null: false
  		t.references :bill
      t.references :isin_info
    end
  end
end