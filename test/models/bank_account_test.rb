require 'test_helper'

class BankAccountTest < ActiveSupport::TestCase
  def setup
    @bank = banks(:one)
    @bank_account = BankAccount.new(bank_id: @bank.id, account_number: 123, default_for_sales: "1", default_for_purchase: "1", ledger_attributes: { opening_blnc: 500, opening_blnc_type: 0})
    @bank_account.ledger = Ledger.new

    # from the controller- following two variables not tested because they will be overrided if bank exists
    @bank_account.ledger.name = "Bank:"+@bank.name+"(#{@bank_account.account_number})"
    @bank_account.bank_name = @bank.name
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

  # Account number
  test "account number should not be string" do
  	@bank_account.account_number = 'quux'
  	assert_not @bank_account.valid?
  end

	test "account number should not be zero" do
  	@bank_account.account_number = 0
  	assert_not @bank_account.valid?
  end

  # << account number boundary tests >>

  # default_for_purchase
  test "default for sales should not be string" do
  	@bank_account.default_for_sales = 'some string'
  	assert_not @bank_account.valid?
  end

  test "default for sales should not be empty" do
  	@bank_account.default_for_sales = ''
  	assert_not @bank_account.valid?
  end

  test "default for sales should not be float" do
  	@bank_account.default_for_sales = '1.5'
  	assert_not @bank_account.valid?
  end

  test "default for sales should not be negative" do
  	@bank_account.default_for_sales = '-1'
  	assert_not @bank_account.valid?
  end

  test "default for sales should not be any integer greater than 1" do
  	@bank_account.default_for_sales = '2'
  	assert_not @bank_account.valid?
  end

  # default_for_purchase
  test "default for purchase should not be string" do
  	@bank_account.default_for_purchase = 'quux'
  	assert_not @bank_account.valid?
  end

  test "default for purchase should not be empty" do
  	@bank_account.default_for_purchase = ''
  	assert_not @bank_account.valid?
  end

  test "default for purchase should not be negative" do
  	@bank_account.default_for_purchase = '-1'
  	assert_not @bank_account.valid?
  end

  # ledger_attributes: opening_balance
  test "opening balance should not be negative" do
  	@bank_account[:ledger_attributes][:opening_blnc] = -500
  	assert_not @bank_account.valid?
  end

  test "opening balance should not be a very large number" do
  	@bank_account[:ledger_attributes][:opening_blnc] = 1234567890234567890
  	assert_not @bank_account.valid?
  end

  test "opening balance should not be string" do
  	@bank_account[:ledger_attributes][:opening_blnc] = 'quux'
  	assert_not @bank_account.valid?
  end

  # << opening balance boundary tests >>
  
  # ledger_attributes: opening_balance_type
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

end
