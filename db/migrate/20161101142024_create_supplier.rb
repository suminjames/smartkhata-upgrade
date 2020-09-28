class CreateSupplier < ActiveRecord::Migration[4.2]
  def change
    create_table :supplier do |t|
      t.string :supplier_name
      t.string :supplier_address
      t.string :supplier_no
      t.string :supplier_email
      t.string :contact_person
      t.string :supplier_fax
      t.string :supplier_id
      t.string :pan_no
      t.string :vat_no
      t.string :supplier_type
      t.string :due_days
      t.string :ac_code
    end
  end
end
