class RemoveColumnsFromLedgers < ActiveRecord::Migration
  def up
    remove_column :ledgers, :opening_blnc
    remove_column :ledgers, :opening_balance_org
    remove_column :ledgers, :closing_balance_org
    remove_column :ledgers, :closing_blnc
  end
end
