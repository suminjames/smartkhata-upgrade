# == Schema Information
#
# Table name: customer_registration
#
#  id                            :integer          not null, primary key
#  customer_code                 :string
#  customer_name                 :string
#  fathers_name                  :string
#  g_father_name                 :string
#  citizenship_no                :string
#  tel_no                        :string
#  fax                           :string
#  email                         :string
#  contact_person                :string
#  customer_address              :string
#  mgr_ac_code                   :string
#  ac_code                       :string
#  group_tag                     :string
#  group_code                    :string
#  dob                           :string
#  dob_bs                        :string
#  birth_reg_no                  :string
#  birth_reg_issued_date         :string
#  ctznp_issued_date             :string
#  ctznp_issued_date_bs          :string
#  ctznp_issued_district_code    :string
#  pan_no                        :string
#  husband_wife_name             :string
#  occupation                    :string
#  organization_name             :string
#  organization_address          :string
#  idcard_no                     :string
#  mobile_no                     :string
#  skype_id                      :string
#  temp_district_code            :string
#  temp_vdc_mp_smp               :string
#  temp_vdc_mp_smp_name          :string
#  temp_tole                     :string
#  temp_ward_no                  :string
#  temp_block_no                 :string
#  per_district_code             :string
#  per_vdc_mp_smp                :string
#  per_vdc_mp_smp_name           :string
#  per_tole                      :string
#  per_ward_no                   :string
#  per_block_no                  :string
#  per_tel_no                    :string
#  per_fax_no                    :string
#  financial_institution_name    :string
#  financial_institution_address :string
#  account_no                    :string
#  company_reg_no                :string
#  company_reg_date              :string
#  company_reg_date_bs           :string
#  business_sector               :string
#  referred_client_code          :string
#  entered_by                    :string
#  entered_bs_date               :string
#  nepse_customer_code           :string
#  demat_ac_no                   :string
#  company_code                  :string
#  mutual_fund                   :string
#  client_account_id             :integer
#

class Mandala::CustomerRegistration < ApplicationRecord
  self.table_name = "customer_registration"
  belongs_to :client_account


  def find_or_create_smartkhata_client_account
    return self.client_account if self.client_account_id.present?

    client_account =  find_or_create_smartkhata_client_account_from_hash(self.attributes)
    self.client_account_id = client_account.id
    self.save!

    client_account
  end

  def find_or_new_smartkhata_client_account
    return self.client_account if self.client_account_id.present?
    find_or_new_smartkhata_client_account_from_hash(self.attributes)
  end


  def find_or_new_smartkhata_client_account_from_hash(hash)
    # to make sure the json and the csv files are compatible
    hash = hash.transform_keys { |key| key.to_s.upcase }
    client_account = nil
    # look for the clients with the nepse code and update the account code for the same
    # the following case is valid when we have clients present in the database
    if hash['NEPSE_CUSTOMER_CODE'].present?
      client_account = ::ClientAccount.find_by(nepse_code: hash['NEPSE_CUSTOMER_CODE'].upcase)
    end

    if client_account
      # skip if client_account has same ac code
      return client_account if client_account.ac_code == hash['AC_CODE']
      client_account.ac_code = hash['AC_CODE']
    else
      client_account = ::ClientAccount.new(ac_code: hash["AC_CODE"], nepse_code: hash['NEPSE_CUSTOMER_CODE'].upcase)
    end


    # grab information from the file and store to the database where applicable
    client_account.name ||= hash["CUSTOMER_NAME"]
    client_account.father_mother ||= hash["FATHERS_NAME"]
    client_account.granfather_father_inlaw ||= hash["G_FATHER_NAME"]
    client_account.citizen_passport ||= hash["CITIZENSHIP_NO"]
    client_account.client_type = hash["GROUP_CODE"] == "COM" ? ClientAccount.client_types[:corporate] : ClientAccount.client_types[:individual]

    # inconclusive dates from the file
    # mandala doesnt enforce it so can find bs date in dob column and vice versa

    client_account.dob ||= hash["DOB"] || hash["DOB_BS"]
    client_account.citizen_passport_date ||= hash["CTZNP_ISSUED_DATE_BS"].gsub('/','-') #validation requires date in format yyyy-mm-dd
    client_account.citizen_passport_district = hash["CTZNP_ISSUED_DISTRICT_CODE"]
    client_account.husband_spouse = hash["HUSBAND_WIFE_NAME"]
    client_account.profession_code = hash["OCCUPATION"]
    client_account.company_name = hash["ORGANIZATION_NAME"]
    client_account.company_address = hash["ORGANIZATION_ADDRESS"]
    client_account.company_id = hash["IDCARD_NO"]
    # mobile number can not have -
    client_account.mobile_number ||= hash["MOBILE_NO"] if hash["MOBILE_NO"].is_a? Integer
    client_account.phone_perm ||= hash["PER_TEL_NO"]
    client_account.address1 ||= "#{hash['TEMP_VDC_MP_SMP_NAME']} - #{ hash['TEMP_TOLE']} - #{hash['TEMP_WARD_NO']}"
    client_account.address1_perm ||= "#{hash['PER_VDC_MP_SMP_NAME']} - #{ hash['PER_TOLE']} - #{hash['PER_WARD_NO']}"

    client_account.citizen_passport_date = client_account.citizen_passport_date.gsub('/','-')
    client_account.dob = client_account.dob.gsub('/','-')

    client_account
  end

  def find_or_create_smartkhata_client_account_from_hash(hash)
    client_account = find_or_new_smartkhata_client_account_from_hash(hash)
    # some issues due to invalid dates in database
    begin
      client_account.save!
    rescue
      client_account.skip_validation_for_system = true
      # client_account.mobile_number = nil
      # client_account.citizen_passport_date = nil
      # client_account.dob = nil
      client_account.save!
    end
    client_account
  end
end
