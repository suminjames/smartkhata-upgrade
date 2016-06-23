require 'test_helper'

class BankAccountTest < ActiveSupport::TestCase
  def setup
    @bank = banks(:one)
    # @bank_account = BankAccount.new(bank_id: @bank.id, account_number: 123, default_for_receipt: "1", default_for_payment: "1", ledger_attributes: { opening_blnc: 500, opening_blnc_type: 0})
    @bank_account = BankAccount.new(bank_id: @bank.id, account_number: 123, default_for_receipt: "1", default_for_payment: "1")
    @bank_account.ledger = Ledger.new

    # from the controller- following two variables not tested because they will be overrided if bank exists
    @bank_account.ledger.name = "Bank:"+@bank.name+"(#{@bank_account.account_number})"
    @bank_account.bank_name = 'Some Bank'
  end

  test "should be valid" do
  	assert @bank_account.valid?
  end

  # Bank id
  test "bank id should be present" do
  	@bank_account.bank_id = ''
  	assert_not @bank_account.valid?

  end
  test "bank id should not be imaginary" do
  	@bank_account.bank_id = 29648592
  	assert_not @bank_account.valid?
  end

  test "bank id should not be negative" do
  	@bank_account.bank_id = -@bank.id
  	assert_not @bank_account.valid?
  end

	test "bank id should not be zero" do
  	@bank_account.bank_id = 0
  	assert_not @bank_account.valid?
  end

  test "bank id should not be string" do
  	@bank_account.bank_id = 'quux'
  	assert_not @bank_account.valid?
  end

  test "account number can be alphanumeric" do
    @bank_account.account_number = 'S0M3VALU3'
    assert @bank_account.valid?
  end

  # invalid account numbers
  test "account number should not be duplicate" do
    @bank_account.account_number = 1234
    assert_not @bank_account.valid?
  end

  # Accepts zero
  # test "account number should not be zero" do
  #   @bank_account.account_number = 0
  #   assert_not @bank_account.valid?
  # end

  test "account number should not be negative" do
    @bank_account.account_number = -947
    assert_not @bank_account.valid?
  end

  test "account number should not be all letters" do
  	@bank_account.account_number = 'quux'
  	assert_not @bank_account.valid?
  end
  test "account number should not contain special characters" do
    @bank_account.account_number = '@123#'
    assert_not @bank_account.valid?
  end

  # ledger_attributes: opening_balance
  test "opening balance should not be negative" do
    @bank_account.ledger.opening_blnc = -500
    assert_not @bank_account.valid?
  end

  # Testing public methods in the model
  test "should change default for payment" do
    a1 = bank_accounts(:one)
    a2 = bank_accounts(:two)
    accounts = [a1, a2]
    accounts.each {|account| account.update_column(:default_for_payment, true) }
    a1.change_default
    accounts.each {|account| account.reload}

    assert     a1.default_for_payment
    assert_not a2.default_for_payment
  end

  test "should change default for sales" do
    a1 = bank_accounts(:one)
    a2 = bank_accounts(:two)
    accounts = [a1, a2]
    accounts.each {|account| account.update_column(:default_for_receipt, true) }
    a1.change_default
    accounts.each {|account| account.reload}

    assert     a1.default_for_receipt
    assert_not a2.default_for_receipt
  end

  test "should get formatted bank name" do
    assert_equal "#{@bank_account.bank.bank_code }-#{@bank_account.account_number}", @bank_account.name
  end

  test "should get bank name" do
    assert_equal "#{@bank_account.bank.name}", @bank_account.bank_name
  end

  # Login required
  # test "should assign group" do
  #   # Group.find_by(name: "Current Assets")
  #   @bank_account.assign_group
  # end

=begin
  # default for sales and purchase-

  # default_for_payment
  test "default for sales should not be string" do
  	@bank_account.default_for_receipt = 'some string'
  	assert_not @bank_account.valid?
  end

  test "default for sales should not be empty" do
  	@bank_account.default_for_receipt = ''
  	assert_not @bank_account.valid?
  end

  test "default for sales should not be float" do
  	@bank_account.default_for_receipt = '1.5'
  	assert_not @bank_account.valid?
  end

  test "default for sales should not be negative" do
  	@bank_account.default_for_receipt = '-1'
  	assert_not @bank_account.valid?
  end

  test "default for sales should not be any integer greater than 1" do
  	@bank_account.default_for_receipt = '2'
  	assert_not @bank_account.valid?
  end

  # default_for_payment
  test "default for purchase should not be string" do
  	@bank_account.default_for_payment = 'quux'
  	assert_not @bank_account.valid?
  end

  test "default for purchase should not be empty" do
  	@bank_account.default_for_payment = ''
  	assert_not @bank_account.valid?
  end

  test "default for purchase should not be negative" do
  	@bank_account.default_for_payment = '-1'
  	assert_not @bank_account.valid?
  end
=end

=begin

  # ledger_attributes: opening_balance_type: boolean field
  test "opening balance type should not be negative" do
  	@bank_account[:ledger_attributes][:opening_blnc_type] = -1
  	assert_not @bank_account.valid?
  end

  test "opening balance type should not be float" do
  	@bank_account[:ledger_attributes][:opening_blnc_type] = 1.5
  	assert_not @bank_account.valid?
  end

  test "opening balance type should not be any integer greater than 1" do
  	@bank_account[:ledger_attributes][:opening_blnc_type] = '2'
  	assert_not @bank_account.valid?
  end

  test "opening balance type should not be string" do
  	@bank_account[:ledger_attributes][:opening_blnc_type] = 'quux'
  	assert_not @bank_account.valid?
  end
=end

end
