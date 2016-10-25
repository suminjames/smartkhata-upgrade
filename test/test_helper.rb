require 'simplecov'
SimpleCov.start unless ENV['NO_COVERAGE']

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
# added minitest reporter for color coding
require "minitest/reporters"
Minitest::Reporters.use!

Apartment::Tenant.drop( "trishakti" ) rescue nil
Apartment::Tenant.create( "trishakti" ) rescue nil
Apartment::Tenant.switch!( "trishakti" )

class ActiveSupport::TestCase

  include FactoryGirl::Syntax::Methods
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  setup do
    new_user = User.find_or_create_by!(email: 'testuser@test.com') do |user|
      user.password = 'test'
      user.password_confirmation = 'test'
      user.branch_id = 1
      user.confirm
    end
    UserSession.user = new_user
    UserSession.selected_branch_id = new_user.branch_id
    UserSession.selected_fy_code = 7374
  end
  # Add more helper methods to be used by all tests here...

  # SAMPLE DATA: Invalid data samples (limited) to be used by various (unit) tests
  INVALID_EMAIL_SAMPLES = ['plainaddress', '%^%#$@#$@#.com', '@example.com', 'email.example.com', 'email@example@example.com',
                           'email@example', 'email@111.222.333.44444', 'email@example..com', 'this\ is"really"not\allowed@example.com',
                           'Joe Smith <email@example.com>', 'email@example.com (Joe Smith)']
  # Assumes YYYY-MM-DD format
  INVALID_DATE_SAMPLES  = ['foo', '234', 'aa-bb-cccc', '12-10-2010', '10-2010-10', '2004-04-40', '2013-13-13']

  INVALID_INTEGER_SAMPLES = ['foo', 'b4r', '3@`/_', '123.45', '.12345', '12345.', '123/45', '123+45', '123*45']


  # UNIT/ FUNCTIONAL HELPERS
  # Checks whether a string/array contains a substring. Not case sensitive.
  def assert_contains(exp_substr, obj, msg=nil)
    msg = message(msg) { "Expected #{mu_pp obj} to contain #{mu_pp exp_substr}" }
    exp_substr.downcase!
    case obj
    when String then obj.downcase!
    when Array  then obj.map!(&:downcase)
    end
    assert_respond_to obj, :include?
    assert obj.include?(exp_substr), msg
  end

  # Asserts that an (AR) object is invalid when given attribute(s) are set to given (or blank) value(s)
  # Does not test multiple attributes for multiple values, as that is done through multiple tests
  def assert_invalid(record, attribute, value='  ')
    assign_and_assert = lambda { |attr, val|
      # Dynamic dispatch!
      record.send("#{attr}=", val)
      assert record.invalid?, "#{record} should be invalid when #{attr} equals '#{val}'"
    }
    if attribute.is_a? Array
      # Test multiple attributes with the same value
      attribute.each { |attr| assign_and_assert.call(attr, value) }
    else
      # Test multiple values for a single attribute
      value.each { |val| assign_and_assert.call(attribute, val) }
    end
  end

  # Sets the branch and fycode into the session from the given (AR) object
  def set_fy_code_and_branch_from(record, unit_test=false)
    set_fy_code(record.fy_code, unit_test)
    set_branch_id(record.branch_id, unit_test)
  end

  # Sets the given fycode into the session
  def set_fy_code(fy_code, unit_test=false)
    UserSession.selected_fy_code = fy_code
    session[:user_selected_fy_code] = fy_code unless unit_test
  end

  # Sets the given branch id into the session
  def set_branch_id(branch_id, unit_test=false)
    UserSession.selected_branch_id = branch_id
    session[:user_selected_branch_id] = branch_id unless unit_test
  end


  # INTEGRATION HELPERS
  def log_in(email=users(:user).email, password='password')
    post_via_redirect new_user_session_path, 'user[email]' => email, 'user[password]' => password
  end

  def set_fy_code_and_branch(fy_code=7273, branch_id=1)
    get general_settings_set_fy_path, {fy_code: 7273, branch_id: 1}
  end

  def set_host(host_name='trishakti.lvh.me')
    host! host_name
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end
