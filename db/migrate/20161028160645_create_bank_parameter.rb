class CreateBankParameter < ActiveRecord::Migration[4.2]
  def change
    create_table :bank_parameter do |t|
      t.string :bank_code
      t.string :bank_name
      t.string :ac_code
      t.string :remarks
    end
  end
end
