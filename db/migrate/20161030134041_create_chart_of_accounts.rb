class CreateChartOfAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :chart_of_account do |t|
      t.string :ac_code
      t.string :sub_code
      t.string :ac_name
      t.string :account_type
      t.string :currency_code
      t.string :control_account
      t.string :sub_ledger
      t.string :reporting_group
      t.string :mgr_ac_code
      t.string :mgr_sub_code
      t.string :fiscal_year
    end
  end
end
