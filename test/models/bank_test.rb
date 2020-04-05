# == Schema Information
#
# Table name: banks
#
#  id         :integer          not null, primary key
#  name       :string
#  bank_code  :string
#  address    :string
#  contact_no :string
#  creator_id :integer
#  updater_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class BankTest < ActiveSupport::TestCase
  def setup
    @bank = Bank.new(bank_code: 'THE_BANK', name:'The Bank Limited')
  end

  test "should be valid" do
    assert @bank.valid?
  end

  test "bank code should not be empty" do
    @bank.bank_code = ''
    assert_not @bank.valid?
  end

  test "bank code should not be blank" do
    @bank.bank_code = '   '
    assert_not @bank.valid?
  end

  test "bank code should not be duplicate" do
    # duplicate bank code from fixtures
    @bank.name = 'MyString'
    assert_not @bank.valid?
  end

  test "bank name should not be blank" do
    @bank.bank_code = '   '
    assert_not @bank.valid?
  end

  test "bank name should not be duplicate" do
    # duplicate bank name from fixtures
    @bank.name = 'MyString'
    assert_not @bank.valid?
  end

end
