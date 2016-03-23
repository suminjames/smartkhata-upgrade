class CreateClientAccounts < ActiveRecord::Migration
  def change
    create_table :client_accounts do |t|
    	t.string :boid
    	t.string :nepse_code
    	t.date :date
    	t.string :name
    	t.string :address1 , default: " "
    	t.string :address1_perm
    	t.string :address2 , default: " "
    	t.string :address2_perm
    	t.string :address3
    	t.string :address3_perm
    	t.string :city, default: " "
    	t.string :city_perm
    	t.string :state
    	t.string :state_perm
    	t.string :country, default: " "
    	t.string :country_perm
    	t.string :phone
    	t.string :phone_perm
    	t.string :customer_product_no
    	t.string :dp_id
    	t.string :dob
    	t.string :sex
    	t.string :nationality
    	t.string :stmt_cycle_code
    	t.string :ac_suspension_fl
    	t.string :profession_code
    	t.string :income_code
    	t.string :electronic_dividend
    	t.string :dividend_curr
    	t.string :email
    	t.string :father_mother
    	t.string :citizen_passport
    	t.string :granfather_father_inlaw
    	t.string :purpose_code_add
    	t.string :add_holder

      t.string :husband_spouse
      t.string :citizen_passport_date
      t.string :citizen_passport_district
      t.string :pan_no
      t.string :dob_ad

      t.string :bank_name
      t.string :bank_account
      t.string :bank_address

      t.string :company_name
      t.string :company_id

    	t.boolean :invited , default: false

    	t.references :user,  index: true
    	t.timestamps null: false
    end
  end
end
