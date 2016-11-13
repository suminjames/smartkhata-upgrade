class CreateVoucherNumberConfiguration < ActiveRecord::Migration
  def change
    create_table :voucher_number_configuration do |t|
      t.string :no_code
      t.string :voucher_no_format
    end
  end
end
