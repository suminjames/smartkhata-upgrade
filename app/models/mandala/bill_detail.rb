# == Schema Information
#
# Table name: bill_detail
#
#  id                    :integer          not null, primary key
#  bill_no               :string
#  no_of_shares          :string
#  company_code          :string
#  rate_per_share        :string
#  amount                :string
#  commission_rate       :string
#  commission_amount     :string
#  budget_code           :string
#  item_name             :string
#  item_rate             :string
#  transaction_no        :string
#  share_code            :string
#  capital_gain          :string
#  name_transfer_rate    :string
#  base_price            :string
#  mutual_capital_gain   :string
#  fiscal_year           :string
#  transaction_fee       :string
#  transaction_type      :string
#  demat_rate            :string
#  no_of_shortage_shares :string
#  close_out_amount      :string
#

class Mandala::BillDetail < ActiveRecord::Base
  self.table_name = "bill_detail"

  def daily_transactions
    Mandala::DailyTransaction.where(transaction_no: transaction_no, transaction_type: transaction_type)
  end
  def daily_transaction
    # it is supposed that daily transaction should be single for a bill detail
    if self.daily_transactions.size != 1
      raise NotImplementedError
    end

    daily_transactions.last
  end
end
