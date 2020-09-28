class CreateVoucherNumberDetail < ActiveRecord::Migration
  def change
    create_table :voucher_number_detail do |t|
      t.string :no_code
      t.string :part_no
      t.string :character_length
      t.string :choice_of_part
      t.string :other_constant
      t.string :number_format
    end
  end
end
