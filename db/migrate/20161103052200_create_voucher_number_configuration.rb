class CreateVoucherNumberConfiguration < ActiveRecord::Migration[4.2]
  def change
    create_table :voucher_number_configuration do |t|
      t.string :no_code
      t.string :voucher_no_format
    end
  end
end
