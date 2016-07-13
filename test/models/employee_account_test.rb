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
