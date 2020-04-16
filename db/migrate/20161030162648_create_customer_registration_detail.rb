class CreateCustomerRegistrationDetail < ActiveRecord::Migration[4.2]
  def change
    create_table :customer_registration_detail do |t|
      t.string :customer_code
      t.string :group_code
      t.string :group_name
      t.string :director_name
      t.string :designation
      t.string :vdc_mp_smp
      t.string :vdc_mp_smp_name
      t.string :tole
      t.string :ward_no
      t.string :phone_no
      t.string :email
      t.string :skype_id
    end
  end
end
