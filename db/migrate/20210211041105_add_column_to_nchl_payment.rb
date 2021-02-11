class AddColumnToNchlPayment < ActiveRecord::Migration
  def change
    add_column :nchl_payments, :token, :text
  end
end
