class CreateDailyTransactionNo < ActiveRecord::Migration[4.2]
  def change
    create_table :daily_transaction_no do |t|
      t.string :transaction_no
      t.string :fiscal_year
    end
  end
end
