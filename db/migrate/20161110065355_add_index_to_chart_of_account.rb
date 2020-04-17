class AddIndexToChartOfAccount < ActiveRecord::Migration[4.2]
  def change
    add_index :chart_of_account, :ac_code
    add_index :chart_of_account, :account_type
  end
end
