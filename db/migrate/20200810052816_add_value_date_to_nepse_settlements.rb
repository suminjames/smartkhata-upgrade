class AddValueDateToNepseSettlements < ActiveRecord::Migration
  def change
    add_column :nepse_settlements, :value_date, :date
  end
end
