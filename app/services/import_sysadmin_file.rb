class ImportSysadminFile < ImportFile
  include ApplicationHelper
  def initialize(file, from_nepse , nepse_boid, boid_nepse = false)
    @from_nepse = from_nepse || false
    @nepse_boid = nepse_boid || false
    @boid_nepse = boid_nepse
    super(file)
  end
# process the file
  def process
    open_file(@file)

    unless @error_message

      if @from_nepse
        ActiveRecord::Base.transaction do
          @processed_data.each do |hash|
            client_account = ClientAccount.find_by(nepse_code:
              hash['Code']
            )
            if client_account.present?
              if SmsMessage.messageable_phone_number?(hash['Phone'])
                client_account.mobile_number = hash['Phone']
              else
                client_account.phone_perm = hash['Phone']
              end

              client_account.save!
            end
          end
        end
      elsif @nepse_boid
        ActiveRecord::Base.transaction do
          @processed_data.each do |hash|
            client_account = ClientAccount.find_by(nepse_code:
                                                       hash['Client Code']
            )
            if client_account.present?
              client_account.boid = hash['BO ID']
              client_account.save!
            end
          end
        end
      elsif @boid_nepse
        ActiveRecord::Base.transaction do
          @processed_data.each do |hash|
            client_account = ClientAccount.find_by(boid:
                                                       hash['BO ID']
            )
            if client_account.present?
              client_account.nepse_code = hash['Client Code']
              client_account.skip_validation_for_file = true
              client_account.save!
            else
              puts 'wtf'
            end

          end
        end
      else
        ActiveRecord::Base.transaction do
          @processed_data.each do |hash|
            if hash['AC_CODE'].blank? || hash['NEPSE_CUSTOMER_CODE'].blank?
              next
            end

            client_account = ClientAccount.find_by(ac_code: hash["AC_CODE"]) || ClientAccount.new(ac_code: hash["AC_CODE"])
            client_account.name = hash["CUSTOMER_NAME"]
            client_account.father_mother = hash["FATHERS_NAME"]
            client_account.granfather_father_inlaw = hash["G_FATHER_NAME"]
            client_account.citizen_passport = hash["CITIZENSHIP_NO"]
            client_account.client_type = hash["GROUP_CODE"] == "COM" ? ClientAccount.client_types[:corporate] : ClientAccount.client_types[:individual]
            client_account.dob = hash["DOB"] || hash["DOB_BS"]
            client_account.citizen_passport_date = hash["CTZNP_ISSUED_DATE_BS"]
            client_account.citizen_passport_district = hash["CTZNP_ISSUED_DISTRICT_CODE"]
            client_account.husband_spouse = hash["HUSBAND_WIFE_NAME"]
            client_account.profession_code = hash["OCCUPATION"]
            client_account.company_name = hash["ORGANIZATION_NAME"]
            client_account.company_address = hash["ORGANIZATION_ADDRESS"]
            client_account.company_id = hash["IDCARD_NO"]
            client_account.nepse_code = hash["NEPSE_CUSTOMER_CODE"].upcase
            client_account.mobile_number = hash["MOBILE_NO"]
            client_account.phone_perm = hash["PER_TEL_NO"]
            client_account.address1 = "#{hash['TEMP_VDC_MP_SMP_NAME']} - #{ hash['TEMP_TOLE']} - #{hash['TEMP_WARD_NO']}"
            client_account.address1_perm = "#{hash['PER_VDC_MP_SMP_NAME']} - #{ hash['PER_TOLE']} - #{hash['PER_WARD_NO']}"
            # product.attributes = row.to_hash.slice(*accessible_attributes)

            client_account.save!
          end
        end
      end
    end
    @processed_data
  end

end
