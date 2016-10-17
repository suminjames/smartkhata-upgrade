# == Schema Information
#
# Table name: ledgers
#
#  id                  :integer          not null, primary key
#  name                :string
#  client_code         :string
#  opening_blnc        :decimal(15, 4)   default(0.0)
#  closing_blnc        :decimal(15, 4)   default(0.0)
#  creator_id          :integer
#  updater_id          :integer
#  fy_code             :integer
#  branch_id           :integer
#  dr_amount           :decimal(15, 4)   default(0.0), not null
#  cr_amount           :decimal(15, 4)   default(0.0), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  group_id            :integer
#  bank_account_id     :integer
#  client_account_id   :integer
#  employee_account_id :integer
#  vendor_account_id   :integer
#  opening_balance_org :decimal(15, 4)   default(0.0)
#  closing_balance_org :decimal(15, 4)   default(0.0)
#

# TODO Testings
# validate :name_from_reserved?, on: :create
require 'test_helper'

class LedgerTest < ActiveSupport::TestCase
  def setup
    @ledger = ledgers(:one)
    @new_ledger = Ledger.new(name: 'foo', opening_blnc: 500)
  end

  test "should be valid" do
    assert @new_ledger.valid?
  end

  test "ledger name should not be blank" do
    @new_ledger.name = '  '
    assert @new_ledger.invalid?
  end

  # test "should store error if ledger name collides with an internal ledger name" do
  #   # Need to add a new ledger "Close Out" in fixtures for this test.(Also update relevant tests eg. basic app flow test)
  #   @new_ledger.name = Ledger::INTERNALLEDGERS[0]
  #   @new_ledger.name_from_reserved?
  #   assert @new_ledger.errors.present?
  # end

  test "opening_balance should not be negative" do
    @new_ledger.opening_blnc = -100_000
    assert @new_ledger.invalid?
  end

  test "should update_closing_balance for debit" do
    initial_opening_balance = @ledger.opening_balance
    assert_equal @ledger.closing_blnc.to_f, 0.0
    @ledger.update_closing_blnc
    @ledger.reload
    assert_equal @ledger.opening_blnc, @ledger.closing_blnc
    assert_equal initial_opening_balance, @ledger.closing_blnc
  end

  test "should update_closing_balance for credit" do
    initial_opening_balance = @ledger.opening_balance
    assert_equal @ledger.closing_blnc.to_f, 0.0
    @ledger.opening_balance_type = Particular.transaction_types['cr']
    @ledger.update_closing_blnc
    @ledger.reload
    assert_equal @ledger.opening_blnc, @ledger.closing_blnc
    assert_equal initial_opening_balance, @ledger.closing_blnc
  end

  test "should store error if negative opening_balance" do
    @ledger.positive_amount
    assert @ledger.errors.none?

    @ledger.opening_blnc = -500
    @ledger.positive_amount
    assert_equal "can't be negative or blank", @ledger.errors[:opening_blnc][0]
  end

  # testing filterrific method
  test "options_for_ledger_select should return appropriate values" do
    params_to_test = [
      nil, #initial state
      {"reset_filterrific"=>"true"}, #when resetting param
      {},
      {"by_ledger_id"=>99999, "by_ledger_type"=>""} #imaginary id
    ]

    # note: assert_empty will fail if nil returned
    params_to_test.each do |param|
      assert_empty Ledger.options_for_ledger_select(param), 'return value not empty when the argument is "#{param.inspect}"'
    end

    # usual hash
    refute_empty Ledger.options_for_ledger_select({"by_ledger_id"=>@ledger.id, "by_ledger_type"=>""})
  end

# Unable to sign-in
# "You may have encountered a bug in the Ruby interpreter or extension libraries."
# (After some hyper error stack > 3000 lines)
=begin
  test "should update_customs" do
    user = users(:user)
    post new_user_session_path, 'user[email]' => user.email, 'user[password]' => 'password'

    @ledger.update_custom({name: 'foo', group_id: 999, vendor_account_id: 111})
    @ledger.reload
    assert_equal ['foo', 999, 111], [@ledger.group_id, @ledger.group_id, @ledger.vendor_account_id]
  end
=end
end
