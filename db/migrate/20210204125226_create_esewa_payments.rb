class CreateEsewaPayments < ActiveRecord::Migration
  def change
    create_table :esewa_payments do |t|
      t.decimal :service_charge #psc
      t.decimal :delivery_charge #pdc
      t.decimal :amount #amt
      t.decimal :tax_amount #txamt
      t.string :success_url #su
      t.string :failure_url #fu
      t.string :response_ref # response reference id sent by esewa
      t.string :response_amount
      t.timestamps null: false
    end
  end
end