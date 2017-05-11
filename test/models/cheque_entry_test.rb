# == Schema Information
#
# Table name: cheque_entries
#
#  id                 :integer          not null, primary key
#  beneficiary_name   :string
#  cheque_number      :integer
#  additional_bank_id :integer
#  status             :integer          default(0)
#  print_status       :integer          default(0)
#  cheque_issued_type :integer          default(0)
#  cheque_date        :date
#  amount             :decimal(15, 4)   default(0.0)
#  bank_account_id    :integer
#  client_account_id  :integer
#  vendor_account_id  :integer
#  settlement_id      :integer
#  voucher_id         :integer
#  creator_id         :integer
#  updater_id         :integer
#  branch_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  fy_code            :integer
#

require 'test_helper'

class ChequeEntryTest < ActiveSupport::TestCase
  def setup
    @bank_account = bank_accounts(:one)
    @cheque_entry = @bank_account.cheque_entries.build(cheque_number: 234)
  end

  test "should be valid" do
    assert @cheque_entry.valid?
  end

  test "cheque number should be present" do
    @cheque_entry = @bank_account.cheque_entries.build(cheque_number: '')
    assert_not @cheque_entry.valid?
  end

  test "cheque number should be unique for a bank" do
    # Cheque no. 123 exists in fixture
    @cheque_entry.cheque_number = 123
    assert_not @cheque_entry.valid?
  end

  test "cheque number should not be negative" do
    @cheque_entry.cheque_number = -234
    assert_not @cheque_entry.valid?
  end

  # test "cheque number should not be string" do
  #   @cheque_entry.cheq
  #   ue_number = 'quux'
  #   assert_not @cheque_entry.valid?
  # end

  test "bank should not be imaginary" do
    cheque_entry = ChequeEntry.new(cheque_number: 234, bank_account_id: 99999)
    assert_not cheque_entry.valid?
  end
end
