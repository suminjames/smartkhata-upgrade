class AddValueDatesForVouchers < ActiveRecord::Migration
  def change
    add_column :vouchers, :value_date, :date
  end
end
