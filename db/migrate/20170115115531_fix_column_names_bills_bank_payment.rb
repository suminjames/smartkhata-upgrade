class FixColumnNamesBillsBankPayment < ActiveRecord::Migration
  def change
    rename_column :bills, :sales_settlement_id, :nepse_settlement_id
    rename_column :bank_payment_letters, :sales_settlement_id, :nepse_settlement_id
  end
end
