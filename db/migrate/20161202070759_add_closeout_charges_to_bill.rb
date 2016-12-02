class AddCloseoutChargesToBill < ActiveRecord::Migration
  def change
    add_column :bills, :closeout_charge, :decimal, precision: 15, scale: 4, default: 0.00
  end
end
