class CreateEmployeeAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :employee_accounts do |t|
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
      t.string :dob
      t.string :sex
      t.string :nationality
      t.string :email
      t.string :father_mother
      t.string :citizen_passport
      t.string :granfather_father_inlaw

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

      t.integer :branch_id, index: true
      t.boolean :invited , default: false

      t.integer :has_access_to, default: 2 # By default employee account has access to nobody
      t.integer :creator_id, index: true
      t.integer :updater_id, index: true
      t.references :user,  index: true
      t.timestamps null: false
    end
  end
end
