class RemoveColumnsFromParticulars < ActiveRecord::Migration
  def up
    remove_column :particulars, :opening_balance
    remove_column :particulars, :running_blnc
  end
end
