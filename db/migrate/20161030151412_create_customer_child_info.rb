class CreateCustomerChildInfo < ActiveRecord::Migration[4.2]
  def change
    create_table :customer_child_info do |t|
      t.string :customer_code
      t.string :child_name
      t.string :relation
      t.string :child_dob
      t.string :child_dob_bs
      t.string :child_birth_reg_no
      t.string :issued_place
    end
  end
end
