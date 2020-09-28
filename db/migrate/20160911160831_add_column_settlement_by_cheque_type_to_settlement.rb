class AddColumnSettlementByChequeTypeToSettlement < ActiveRecord::Migration
  def change
    add_column :settlements, :settlement_by_cheque_type,  :integer, default: 0
  end
end
