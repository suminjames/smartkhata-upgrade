class AddReferencesToSalesSettlement < ActiveRecord::Migration
  def change
    add_reference :sales_settlements, :share_transaction, index: true
    add_reference :sales_settlements, :nepse_provisional_settlement, index: true
  end
end
