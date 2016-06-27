=begin
require 'test_helper'

class ClientAccountTest < ActiveSupport::TestCase
  def setup
    @client_account = ClientAccount.new(name: 'New Client', citizen_passport: '123456', dob: '1900-01-01', father_mother: 'foo', granfather_father_inlaw: 'bar',
                                        address1_perm: 'baz', city_perm: 'alpha', state_perm: 'beta', country_perm: 'gamma')
  end

  test "should be valid" do
    assert @client_account.valid?
  end

  # requires sign-in
  test "should create client ledger" do; end
  test "should assign group" do; end

  # Validations should be put in the controller, if any
  test "client name should not be empty" do
    @client_account.name = '  '
    assert @client_account.invalid?
  end

  test "citizen_passport should not be empty" do
    @client_account.citizen_passport = '  '
    assert @client_account.invalid?
  end

  test "DOB should not be empty" do
    @client_account.dob = '  '
    assert @client_account.invalid?
  end

  test "DOB should not be letters" do
    @client_account.dob = 'foo'
    assert @client_account.invalid?
  end

  test "DOB should not be just numbers" do
    @client_account.dob = '234'
    assert @client_account.invalid?
  end

  test "DOB should not be in invalid format" do
    @client_account.dob = '12-10-2010'
    assert @client_account.invalid?
  end

  test "DOB should not be out of range" do
    @client_account.dob = '2010-10-50'
    assert @client_account.invalid?
  end

  test "father_mother name should not be empty" do
    @client_account.father_mother = '  '
    assert @client_account.invalid?
  end

  test "grandfather or father in law name should not be empty" do
    @client_account.granfather_father_inlaw = '  '
    assert @client_account.invalid?
  end

  test "Address 1 permanent should not be empty" do
    @client_account.address1_perm = '  '
    assert @client_account.invalid?
  end

  test "city permanent address should not be empty" do
    @client_account.granfather_father_inlaw = '  '
    assert @client_account.invalid?
  end

  test "state permanent address should not be empty" do
    @client_account.state_perm = '  '
    assert @client_account.invalid?
  end

  test "country permanent address should not be empty" do
    @client_account.country_perm = '  '
    assert @client_account.invalid?
  end
end
=end