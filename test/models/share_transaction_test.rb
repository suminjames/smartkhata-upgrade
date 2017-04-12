# == Schema Information
#
# Table name: share_transactions
#
#  id                        :integer          not null, primary key
#  contract_no               :decimal(18, )
#  buyer                     :integer
#  seller                    :integer
#  raw_quantity              :integer
#  quantity                  :integer
#  share_rate                :decimal(10, 4)   default(0.0)
#  share_amount              :decimal(15, 4)   default(0.0)
#  sebo                      :decimal(15, 4)   default(0.0)
#  commission_rate           :string
#  commission_amount         :decimal(15, 4)   default(0.0)
#  dp_fee                    :decimal(15, 4)   default(0.0)
#  cgt                       :decimal(15, 4)   default(0.0)
#  net_amount                :decimal(15, 4)   default(0.0)
#  bank_deposit              :decimal(15, 4)   default(0.0)
#  transaction_type          :integer
#  settlement_id             :decimal(18, )
#  base_price                :decimal(15, 4)   default(0.0)
#  amount_receivable         :decimal(15, 4)   default(0.0)
#  closeout_amount           :decimal(15, 4)   default(0.0)
#  remarks                   :string
#  purchase_price            :decimal(15, 4)   default(0.0)
#  capital_gain              :decimal(15, 4)   default(0.0)
#  adjusted_sell_price       :decimal(15, 4)   default(0.0)
#  date                      :date
#  deleted_at                :date
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  nepse_chalan_id           :integer
#  creator_id                :integer
#  updater_id                :integer
#  branch_id                 :integer
#  voucher_id                :integer
#  bill_id                   :integer
#  client_account_id         :integer
#  isin_info_id              :integer
#  transaction_message_id    :integer
#  transaction_cancel_status :integer          default(0)
#

require 'test_helper'

class ShareTransactionTest < ActiveSupport::TestCase
  include CommissionModule

  def setup
    @sales_share_transactions =  ShareTransaction.selling
  end

  test "calculated base_price of purchased share transaction should be 0" do
    share_transaction = ShareTransaction.buying.last
    assert_equal share_transaction.calculate_base_price, 0
  end

  test "calculated base_price of sold but unsettled share transaction should be 0" do
    share_transaction = @sales_share_transactions.where(settlement_id: nil).last
    assert_equal share_transaction.calculate_base_price, 0
  end

  test "calculated base_price of sold but wholly closeout'ed share transaction should be 0" do
    share_transaction = @sales_share_transactions.where(quantity: 0).last
    assert_equal share_transaction.calculate_base_price, 0
  end

  test "should correctly calculate base price of sold share transaction with flat rate commission" do
    share_transaction = @sales_share_transactions.where(commission_rate: 'flat_25').last
    share_transaction.date = "2017-01-01"
    share_transaction.quantity = 10
    share_transaction.purchase_price = 1006.15
    assert_equal share_transaction.calculate_base_price, 98
  end

  test "should correctly calculate base price of sold share transaction with non flat rate commission but purchase price with flat rate commission" do
    share_transaction = @sales_share_transactions.where.not(commission_rate: 'flat_25').where.not(settlement_id: nil).last
    share_transaction.date = "2017-01-01"
    share_transaction.quantity = 26
    # This purchase price falls under the flat rate commission for the date provided.
    share_transaction.purchase_price = 2615.99
    assert_equal share_transaction.calculate_base_price, 99
  end

  test "should correctly calculate base price of sold share transaction with commission rate equal to that of purchase price " do
    share_transaction = @sales_share_transactions.where.not(commission_rate: 'flat_25').where.not(settlement_id: nil).last
    share_transaction.date = "2017-01-01"
    share_transaction.quantity = 10
    share_transaction.share_amount = 18490.0
    # This purchase price falls under the same commission rate as that of share amount
    share_transaction.purchase_price = 17399.22
    assert_equal share_transaction.calculate_base_price, 1729
  end

end
