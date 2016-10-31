class CreateCommissionRates < ActiveRecord::Migration
  def change
    create_table :commission_rate do |t|
      t.string :un_id
      t.integer :amount_below, limit: 8
      t.integer :amount_above, limit: 8
      t.float :rate
      t.decimal :commission_amount, precision: 15, scale: 4
    end
  end
end
