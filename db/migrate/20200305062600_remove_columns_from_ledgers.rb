class RemoveColumnsFromLedgers < ActiveRecord::Migration[4.2]
  def up
    remove_column :ledgers, :opening_blnc
    remove_column :ledgers, :opening_balance_org
    remove_column :ledgers, :closing_balance_org
    remove_column :ledgers, :closing_blnc
    remove_column :ledgers, :dr_amount
    remove_column :ledgers, :cr_amount
  end
end
