class AddDebitCreditToLedger < ActiveRecord::Migration
  def change
    add_column :ledgers, :dr_amount, :decimal, :precision => 15, :scale => 4, :default => 0.00, null: false
    add_column :ledgers, :cr_amount, :decimal, :precision => 15, :scale => 4, :default => 0.00, null: false
  end
end
