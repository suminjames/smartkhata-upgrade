class CreateCustomerRegistration < ActiveRecord::Migration
  def change
    create_table :customer_registration do |t|
      t.integer :customer_code
      t.string :customer_name
      t.string :fathers_name
      t.string :g_father_name
      t.string :citizenship_no
      t.string :tel_no
      t.string :fax
      t.string :email
      t.string :contact_person
      t.string :customer_address
      t.string :mgr_ac_code
      t.string :ac_code
      t.string :group_tag
      t.string :group_code
      t.date :dob
      t.string :dob_bs
      t.string :birth_reg_no
      t.string :birth_reg_issued_date
      t.string :ctznp_issued_date
      t.string :ctznp_issued_date_bs
      t.string :ctznp_issued_district_code
      t.string :pan_no
      t.string :husband_wife_name
      t.string :occupation
      t.string :organization_name
      t.string :organization_address
      t.string :idcard_no
      t.string :mobile_no
      t.string :skype_id
      t.string :temp_district_code
      t.string :temp_vdc_mp_smp
      t.string :temp_vdc_mp_smp_name
      t.string :temp_tole
      t.string :temp_ward_no
      t.string :temp_block_no
      t.string :per_district_code
      t.string :per_vdc_mp_smp
      t.string :per_vdc_mp_smp_name
      t.string :per_tole
      t.string :per_ward_no
      t.string :per_block_no
      t.string :per_tel_no
      t.string :per_fax_no
      t.string :financial_institution_name
      t.string :financial_institution_address
      t.string :account_no
      t.string :company_reg_no
      t.date :company_reg_date
      t.string :company_reg_date_bs
      t.string :business_sector
      t.string :referred_client_code
      t.string :entered_by
      t.string :entered_bs_date
      t.string :nepse_customer_code
      t.string :demat_ac_no
      t.string :company_code
      t.string :mutual_fund
    end
  end
end
