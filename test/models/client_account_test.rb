# == Schema Information
#
# Table name: client_accounts
#
#  id                        :integer          not null, primary key
#  boid                      :string
#  nepse_code                :string
#  client_type               :integer          default("0")
#  date                      :date
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
#  customer_product_no       :string
#  dp_id                     :string
#  dob                       :string
#  sex                       :string
#  nationality               :string
#  stmt_cycle_code           :string
#  ac_suspension_fl          :string
#  profession_code           :string
#  income_code               :string
#  electronic_dividend       :string
#  dividend_curr             :string
#  email                     :string
#  father_mother             :string
#  citizen_passport          :string
#  granfather_father_inlaw   :string
#  purpose_code_add          :string
#  add_holder                :string
#  husband_spouse            :string
#  citizen_passport_date     :string
#  citizen_passport_district :string
#  pan_no                    :string
#  dob_ad                    :string
#  bank_name                 :string
#  bank_account              :string
#  bank_address              :string
#  company_name              :string
#  company_address           :string
#  company_id                :string
#  invited                   :boolean          default("false")
#  referrer_name             :string
#  group_leader_id           :integer
#  creator_id                :integer
#  updater_id                :integer
#  branch_id                 :integer
#  user_id                   :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  mobile_number             :string
#  ac_code                   :string
#

require 'test_helper'

class ClientAccountTest < ActiveSupport::TestCase
  def setup
    @client_account = ClientAccount.new(name: 'New Client', citizen_passport: '123456', dob: '1900-01-01', father_mother: 'foo', granfather_father_inlaw: 'bar',
                                        address1_perm: 'baz', city_perm: 'qux', state_perm: 'quux', country_perm: 'garply')
  end

  test "should be valid" do
    assert @client_account.valid?
  end

  test "Necessary fields should not be empty" do
    empty_attributes = %w(name citizen_passport dob father_mother granfather_father_inlaw address1_perm city_perm state_perm country_perm)
    assert_invalid @client_account, empty_attributes
  end

  test "DOB should be valid" do
    test_date_field :dob
  end

  test "Citizen passport date should be valid" do
    test_date_field :citizen_passport_date
  end

  test "Mobile number should be valid" do
    assert @client_account.valid?
    # Length or format not checked for now
    assert_invalid @client_account, :mobile_number, INVALID_INTEGER_SAMPLES
  end


  private
    def test_date_field(attr)
      assert_invalid @client_account, attr, INVALID_DATE_SAMPLES
    end
end

  # requires sign-in
  # test "should create client ledger" do; end
  # test "should assign group" do; end
