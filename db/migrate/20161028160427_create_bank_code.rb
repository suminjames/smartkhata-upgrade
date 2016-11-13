class CreateBankCode < ActiveRecord::Migration
  def change
    create_table :bank_code do |t|
      t.string :bank_code
      t.string :bank_name
      t.string :ac_code
      t.string :remarks
    end
  end
end
