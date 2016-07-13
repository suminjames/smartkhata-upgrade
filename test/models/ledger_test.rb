require 'test_helper'

class LedgerTest < ActiveSupport::TestCase
  def setup
    @ledger = ledgers(:one)
    @new_ledger = Ledger.new(name: 'foo', opening_balance: 500)
  end

  test "should be valid" do
    assert @new_ledger.valid?
  end

  test "ledger name should not be blank" do
    @new_ledger.name = '  '
    assert @new_ledger.invalid?
  end

  test "opening_balance should not be negative" do
    @new_ledger.opening_balance = -100_000
    assert @new_ledger.invalid?
  end

  test "should update_closing_balance for debit" do
    initial_opening_balance = @ledger.opening_balance
    assert_equal @ledger.closing_balance.to_f, 0.0
    @ledger.update_closing_balance
    @ledger.reload
    assert_equal @ledger.opening_balance, @ledger.closing_balance
    assert_equal initial_opening_balance, @ledger.closing_balance
  end

  test "should update_closing_balance for credit" do
    initial_opening_balance = @ledger.opening_balance
    assert_equal @ledger.closing_balance.to_f, 0.0
    @ledger.opening_balance_type = Particular.transaction_types['cr']
    @ledger.update_closing_balance
    @ledger.reload
    assert_equal @ledger.opening_balance,  @ledger.closing_balance
    assert_equal -initial_opening_balance, @ledger.closing_balance
  end

  test "should store error if negative opening_balance" do
    @ledger.positive_amount
    assert @ledger.errors.none?

    @ledger.opening_balance = -500
    @ledger.positive_amount
    assert_equal "can't be negative or blank", @ledger.errors[:opening_balance][0]
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
