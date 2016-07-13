# == Schema Information
#
# Table name: employee_accounts
#
#  id                        :integer          not null, primary key
#  name                      :string
#  address1                  :string           default(" ")
#  address1_perm             :string
#  address2                  :string           default(" ")
#  address2_perm             :string
#  address3                  :string
#  address3_perm             :string
#  city                      :string           default(" ")
#  city_perm                 :string
#  state                     :string
#  state_perm                :string
#  country                   :string           default(" ")
#  country_perm              :string
#  phone                     :string
#  phone_perm                :string
#  dob                       :string
#  sex                       :string
#  nationality               :string
#  email                     :string
#  father_mother             :string
#  citizen_passport          :string
#  granfather_father_inlaw   :string
#  husband_spouse            :string
#  citizen_passport_date     :string
#  citizen_passport_district :string
#  pan_no                    :string
#  dob_ad                    :string
#  bank_name                 :string
#  bank_account              :string
#  bank_address              :string
#  company_name              :string
#  company_id                :string
#  branch_id                 :integer
#  invited                   :boolean          default("false")
#  has_access_to             :integer          default("2")
#  creator_id                :integer
#  updater_id                :integer
#  user_id                   :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require 'test_helper'

class EmployeeAccountTest < ActiveSupport::TestCase
  def setup
    @employee_account = EmployeeAccount.new(name: 'foo', email: 'foo@example.com')
  end

  test 'should be valid' do
    assert @employee_account.valid?
  end

  test 'name should not be blank' do
    @employee_account.name = '  '
    assert @employee_account.invalid?
  end

  test 'email should not be blank' do
    @employee_account.email = '  '
    assert @employee_account.invalid?
  end

  test 'email should be valid' do
    INVALID_EMAIL_SAMPLES.each do |email|
      @employee_account.email = email
      assert @employee_account.invalid?
    end
  end

  test 'email should not be duplicate' do
    @employee_account.email = 'cynthia@example.com'
    assert @employee_account.invalid?
  end
end
