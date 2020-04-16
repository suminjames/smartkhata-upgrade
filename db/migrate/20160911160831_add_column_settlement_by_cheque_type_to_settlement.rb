class AddColumnSettlementByChequeTypeToSettlement < ActiveRecord::Migration[4.2]
  def change
    add_column :settlements, :settlement_by_cheque_type,  :integer, default: 0
  end
end
