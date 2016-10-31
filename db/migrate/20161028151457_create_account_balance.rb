class CreateAccountBalance < ActiveRecord::Migration
  def change
    create_table :account_balance do |t|
      t.string :ac_code
      t.string :sub_code
      t.decimal :balance_amount, precision: 15, scale: 4
      t.date :balance_date
      t.string :fiscal_year
      t.string :balance_type
      t.decimal :nrs_balance_amount, precision: 15, scale: 4
      t.string :closed_by
      t.date :closed_date
    end
  end
end
