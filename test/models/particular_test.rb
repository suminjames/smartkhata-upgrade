# == Schema Information
#
# Table name: particulars
#
#  id                     :integer          not null, primary key
#  opening_blnc           :decimal(15, 4)   default(0.0)
#  transaction_type       :integer
#  ledger_type            :integer          default(0)
#  cheque_number          :integer
#  name                   :string
#  description            :string
#  amount                 :decimal(15, 4)   default(0.0)
#  running_blnc           :decimal(15, 4)   default(0.0)
#  additional_bank_id     :integer
#  particular_status      :integer          default(1)
#  date_bs                :string
#  creator_id             :integer
#  updater_id             :integer
#  fy_code                :integer
#  branch_id              :integer
#  transaction_date       :date
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  ledger_id              :integer
#  voucher_id             :integer
#  bank_payment_letter_id :integer
#  hide_for_client        :boolean          default(FALSE)
#

require 'test_helper'

class ParticularTest < ActiveSupport::TestCase
  def setup
    @particular = Particular.new(ledger: ledgers(:one))
  end

  test "should be valid" do
    assert @particular.valid?
  end

  test "ledger should be present" do
    @particular.ledger = nil
    assert @particular.invalid?
  end
end
