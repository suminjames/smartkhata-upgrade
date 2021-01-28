class AddValueDateToNepseSettlements < ActiveRecord::Migration[4.2]
  def change
    add_column :nepse_settlements, :value_date, :date
  end
end
