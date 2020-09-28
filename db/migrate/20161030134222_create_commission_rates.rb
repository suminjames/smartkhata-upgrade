class CreateCommissionRates < ActiveRecord::Migration[4.2]
  def change
    create_table :commission_rate do |t|
      t.string :un_id
      t.string :amount_below
      t.string :amount_above
      t.string :rate
      t.string :commission_amount
    end
  end
end
