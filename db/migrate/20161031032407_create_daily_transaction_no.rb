class CreateDailyTransactionNo < ActiveRecord::Migration
  def change
    create_table :daily_transaction_no do |t|
      t.integer :transaction_no, limit: 8
      t.string :fiscal_year
    end
  end
end
