# == Schema Information
#
# Table name: bank_accounts
#
#  id                  :integer          not null, primary key
#  account_number      :string
#  bank_name           :string
#  default_for_payment :boolean
#  default_for_receipt :boolean
#  creator_id          :integer
#  updater_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  bank_id             :integer
#  branch_id           :integer
#  bank_branch         :string
#  address             :text
#  contact_no          :string
#

require 'test_helper'

class BankAccountTest < ActiveSupport::TestCase
  def setup
    @bank = banks(:one)
    # @bank_account = BankAccount.new(bank_id: @bank.id, account_number: 123, default_for_receipt: "1", default_for_payment: "1", ledger_attributes: { opening_balance: 500, opening_balance_type: 0})
    @bank_account = BankAccount.new(bank_id: @bank.id, account_number: 123, default_for_receipt: "1", default_for_payment: "1", bank_branch: "utopian")
    @bank_account.ledger = Ledger.new

    # from the controller- following two variables not tested because they will be overrided if bank exists
    @bank_account.ledger.name = "Bank:"+@bank.name+"(#{@bank_account.account_number})"
    @bank_account.bank_name = 'Some Bank'
    set_branch_id(1, true)
  end

  # test "should be valid" do
  #   assert @bank_account.valid?
  # end

  # Bank id
  test "bank id should not be empty, imaginary, negative, zero or pure letters" do
    assert_invalid @bank_account, :bank_id, [' ', 29648592, -@bank.id, 0, 'quux']
  end

  # test "account number can be alphanumeric" do
  #   @bank_account.account_number = 'S0M3VALU3'
  #   assert @bank_account.valid?
  # end

  # invalid account numbers
  test "account number should not be duplicate, negative, all letters or contain special characters" do
    assert_invalid @bank_account, :account_number, [1234, -947, 'quux', '@123#']
  end

  # ledger_attributes: opening_balance
  test "opening balance should not be negative" do
    @bank_account.ledger.opening_blnc = -500
    assert_not @bank_account.valid?
  end

  # # Testing public methods in the model
  # test "should change default for payment" do
  #   a1 = bank_accounts(:one)
  #   a2 = bank_accounts(:two)
  #   # debugger
  #   accounts = [a1, a2]
  #   accounts.each {|account| account.update_column(:default_for_payment, true) }
  #   a1.change_default
  #   accounts.each {|account| account.reload}
  #
  #   # debugger
  #   assert     a1.default_for_payment
  #   assert_not a2.default_for_payment
  # end

  # test "should change default for sales" do
  #   a1 = bank_accounts(:one)
  #   a2 = bank_accounts(:two)
  #   accounts = [a1, a2]
  #   accounts.each {|account| account.update_column(:default_for_receipt, true) }
  #   a1.change_default
  #   accounts.each {|account| account.reload}
  #
  #   assert     a1.default_for_receipt
  #   assert_not a2.default_for_receipt
  # end

  # test "should get formatted bank name" do
  #   assert_equal "#{@bank_account.bank.bank_code }-#{@bank_account.account_number}", @bank_account.name
  # end
  #
  # test "should get bank name" do
  #   assert_equal "#{@bank_account.bank.name}", @bank_account.bank_name
  # end


  # test "should create a new bank accout with ledger" do
  #   bank = create(:bank)
  #   ledger = build(:ledger)
  #   bank_account = build(:bank_account, bank: bank, branch_id: 1)
  #   bank_account.ledger = ledger
  #   ledger_balance = build(:ledger_balance, ledger_id: ledger.id, opening_balance: 1000, branch_id: 1)
  #   bank_account.ledger.ledger_balances << ledger_balance
  #
  #   UserSession.selected_branch_id = 1
  #   assert bank_account.save_custom
  #
  #   name = "Bank:"+bank.name+"(#{bank_account.account_number})"
  #   bank_ledger = bank_account.ledger
  #   assert_equal 1000, bank_ledger.closing_balance
  #   UserSession.selected_branch_id = 2
  #   assert_equal 0, bank_ledger.closing_balance
  #   assert_equal name, bank_ledger.name
  #
  #   # params = {
  #   #     "bank_id" => "2",
  #   #     "account_number" => "343",
  #   #     "bank_branch" => "asdf",
  #   #     "contact_no" => "",
  #   #     "address" => "",
  #   #     "default_for_receipt" => "0",
  #   #     "default_for_payment" => "0",
  #   #     "branch_id" => "2",
  #   #     "ledger_attributes" => {
  #   #         "group_id" => "18",
  #   #         "ledger_balances_attributes" => {
  #   #             "0" => {
  #   #                 "opening_balance" => "1000",
  #   #                 "opening_balance_type" => "dr",
  #   #                 "branch_id" => "2"
  #   #             }
  #   #         }
  #   #     }
  #   # }
  #
  # end


end
