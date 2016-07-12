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
