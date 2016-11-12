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
  # test "the truth" do
  #   assert true
  # end
end
