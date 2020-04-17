class AddCloseoutChargesToBill < ActiveRecord::Migration[4.2]
  def change
    add_column :bills, :closeout_charge, :decimal, precision: 15, scale: 4, default: 0.00
  end
end
