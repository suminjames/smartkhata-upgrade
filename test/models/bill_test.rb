# == Schema Information
#
# Table name: bills
#
#  id                         :integer          not null, primary key
#  bill_number                :integer
#  client_name                :string
#  net_amount                 :decimal(15, 4)   default("0")
#  balance_to_pay             :decimal(15, 4)   default("0")
#  bill_type                  :integer
#  status                     :integer          default("0")
#  special_case               :integer          default("0")
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  fy_code                    :integer
#  date                       :date
#  date_bs                    :string
#  settlement_date            :date
#  client_account_id          :integer
#  creator_id                 :integer
#  updater_id                 :integer
#  branch_id                  :integer
#  sales_settlement_id        :integer
#  settlement_approval_status :integer          default("0")
#

require "#{Rails.root}/app/globalhelpers/custom_date_module"
require 'test_helper'

class BillTest < ActiveSupport::TestCase
  include CustomDateModule
  def setup
    share_transaction = ShareTransaction.selling.first
    bs_date = ad_to_bs(share_transaction.date.to_s)
    client_account = share_transaction.client_account
    @bill = Bill.new(date_bs: bs_date, provisional_base_price: '1000', client_account_id: client_account.id)
  end

  test "should be valid" do
    assert @bill.valid?
  end

  test "client_account_id should not be empty" do
    @bill.client_account_id = ' '
    assert @bill.invalid?
  end

  test "client_account_id should not be imaginary" do
    @bill.client_account_id = '3740237'
    assert @bill.invalid?
  end
end
