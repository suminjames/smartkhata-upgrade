class ChangeColumnsToBill < ActiveRecord::Migration
  def change
    change_column :bills, :net_amount, :decimal, :precision => 15, :scale => 4, default: 0.0
    change_column :bills, :balance_to_pay, :decimal, :precision => 15, :scale => 4, default: 0.0
    change_column :bills, :closeout_charge, :decimal, :precision => 15, :scale => 4, default: 0.0
  end
end
