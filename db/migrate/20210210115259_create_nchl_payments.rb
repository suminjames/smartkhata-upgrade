class CreateNchlPayments < ActiveRecord::Migration
  def change
    create_table :nchl_payments do |t|
      t.string :reference_id
      t.text :remarks
      t.text :particular
      t.text :token

      t.timestamps null: false
    end
  end
end
