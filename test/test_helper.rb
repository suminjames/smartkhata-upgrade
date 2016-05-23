ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
# added minitest reporter for color coding
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  # fixtures :banks, :bank_accounts, :users, :ledgers, :vouchers, :particulars

  # Add more helper methods to be used by all tests here...

  # Checks whether a string/array contains a substring. Not case sensitive.
  def assert_contains(exp_substr, obj, msg=nil)
    msg = message(msg) { "Expected #{mu_pp obj} to contain #{mu_pp exp_substr}" }
    exp_substr.downcase!
    if obj.is_a? String
      obj.downcase!
    elsif obj.is_a? Array
      obj.map!(&:downcase)
    end
    assert_respond_to obj, :include?
    assert obj.include?(exp_substr), msg
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end
