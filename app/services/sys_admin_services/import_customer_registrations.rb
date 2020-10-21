class SysAdminServices::ImportCustomerRegistrations < ImportFile
  include ApplicationHelper

  def process
    open_file(@file)
    unless @error_message
      ActiveRecord::Base.transaction do
        @processed_data.each do |hash|
          # we will consider clients with  account code and the nepse customer code
          next if hash['AC_CODE'].blank? || hash['NEPSE_CUSTOMER_CODE'].blank?

          # look for the clients with the nepse code and update the account code for the same
          # the following case is valid when we have clients present in the database
          client_account = ClientAccount.find_by(nepse_code: hash['NEPSE_CUSTOMER_CODE'].upcase)

          if client_account
            # skip if client_account has same ac code
            next if client_account.ac_code == hash['AC_CODE']

            client_account.ac_code = hash['AC_CODE']
          else
            client_account = ClientAccount.new(ac_code: hash["AC_CODE"], nepse_code: hash['NEPSE_CUSTOMER_CODE'].upcase)
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
          client_account.citizen_passport_date ||= hash["CTZNP_ISSUED_DATE_BS"].tr('/', '-') # validation requires date in format yyyy-mm-dd
          client_account.citizen_passport_district = hash["CTZNP_ISSUED_DISTRICT_CODE"]
          client_account.husband_spouse = hash["HUSBAND_WIFE_NAME"]
          client_account.profession_code = hash["OCCUPATION"]
          client_account.company_name = hash["ORGANIZATION_NAME"]
          client_account.company_address = hash["ORGANIZATION_ADDRESS"]
          client_account.company_id = hash["IDCARD_NO"]
          # mobile number can not have -
          client_account.mobile_number ||= hash["MOBILE_NO"] if hash["MOBILE_NO"].is_a? Integer
          client_account.phone_perm ||= hash["PER_TEL_NO"]
          client_account.address1 ||= "#{hash['TEMP_VDC_MP_SMP_NAME']} - #{hash['TEMP_TOLE']} - #{hash['TEMP_WARD_NO']}"
          client_account.address1_perm ||= "#{hash['PER_VDC_MP_SMP_NAME']} - #{hash['PER_TOLE']} - #{hash['PER_WARD_NO']}"

          client_account.citizen_passport_date = client_account.citizen_passport_date.tr('/', '-')
          client_account.dob = client_account.dob.tr('/', '-')

          # some issues due to invalid dates in database
          begin
            client_account.save!
          rescue
            client_account.mobile_number = nil
            client_account.citizen_passport_date = nil
            client_account.dob = nil
            client_account.save!
          end
        end
      end
    end
  end
end
