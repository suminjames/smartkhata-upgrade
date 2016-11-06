class CreateAccountBalance < ActiveRecord::Migration
  def change
    create_table :account_balance do |t|
      t.string :ac_code
      t.string :sub_code
      t.string :balance_amount
      t.string :balance_date
      t.string :fiscal_year
      t.string :balance_type
      t.string :nrs_balance_amount
      t.string :closed_by
      t.string :closed_date
    end
  end
end
