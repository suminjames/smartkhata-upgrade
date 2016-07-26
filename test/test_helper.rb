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
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # (limited) Invalid data samples to be used by various tests
  INVALID_EMAIL_SAMPLES = ['plainaddress', '%^%#$@#$@#.com', '@example.com', 'email.example.com', 'email@example@example.com',
                           'email@example', 'email@111.222.333.44444', 'email@example..com', 'this\ is"really"not\allowed@example.com',
                           'Joe Smith <email@example.com>', 'email@example.com (Joe Smith)']
  # Assumes YYYY-MM-DD format
  INVALID_DATE_SAMPLES  = ['foo', '234', 'aa-bb-cccc', '12-10-2010', '10-2010-10', '2004-04-40', '2013-13-13']

  INVALID_INTEGER_SAMPLES = ['foo', 'b4r', '3@`/_', '123.45', '.12345', '12345.', '123/45', '123+45', '123*45']

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

  # Asserts that an (active record) object is invalid when given attribute(s) are set to given (or blank) value(s)
  def assert_invalid(record, attribute, value='  ')
    assign_and_assert = lambda { |attr, val|
      # Dynamic dispatch!
      record.send("#{attr}=", val)
      assert record.invalid?
    }
    if attribute.is_a? Array
      # Test multiple attributes with the same value
      attribute.each { |attr| assign_and_assert.call(attr, value) }
    else
      # Test multiple values for a single attribute
      value.each { |val| assign_and_assert.call(attribute, val) }
    end
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end
