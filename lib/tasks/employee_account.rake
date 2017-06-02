
namespace :employee_account do

  desc "Sync employee_account from csv"
  task :sync_with_csv_data,[:tenant, :mimic] => 'smartkhata:validate_tenant' do |task, args|

    mimic = args[:mimic] == 'true' ? true : false

    dir = "#{Rails.root}/test_files/"
    employee_account_csv_file =  dir + 'employee_accounts.csv'

    csv_text = File.read(employee_account_csv_file)
    csv = CSV.parse(csv_text, :headers => true)
    employee_accounts_from_csv_arr = []

    csv.each do |row|
      employee_accounts_from_csv_arr << row.to_hash
    end

    relevant_attributes = [
        "name",
        "address1",
        "address1_perm",
        "address2",
        "address2_perm",
        "address3",
        "address3_perm",
        "city",
        "city_perm",
        "state",
        "state_perm",
        "country",
        "country_perm",
        "phone",
        "phone_perm",
        "dob",
        "sex",
        "nationality",
        "email",
        "father_mother",
        "citizen_passport",
        "granfather_father_inlaw",
        "husband_spouse",
        "citizen_passport_date",
        "citizen_passport_district",
        "pan_no",
        "dob_ad",
        "bank_name",
        "bank_account",
        "bank_address",
        "company_name",
        "company_id",
        "branch_id",
        "invited",
    ]

    integer_attrs = [
        "invited",
        'branch_id'
    ]

    ActiveRecord::Base.transaction do
      employee_accounts_from_csv_arr.each do |employee_account_from_csv|
        EmployeeAccount.find_or_create_by!(email: employee_account_from_csv["email"]) do |employee_account|
          # update relevant attributes
          relevant_attributes.each do |attr|
            if employee_account_from_csv[attr].present?
              if integer_attrs.include?(attr)
                employee_account_from_csv[attr] =  employee_account_from_csv[attr].to_i
              end
              employee_account.send("#{attr}=", employee_account_from_csv[attr])
            end
          end
        end
      end
    end

  end
end
