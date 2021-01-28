class AddValueDatesForVouchers < ActiveRecord::Migration[4.2]
  def change
    add_column :vouchers, :value_date, :date
  end
end
