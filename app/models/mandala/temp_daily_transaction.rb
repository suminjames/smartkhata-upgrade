# == Schema Information
#
# Table name: temp_daily_transaction
#
#  id                  :integer          not null, primary key
#  transaction_no      :string
#  company_code        :string
#  buyer_broker_no     :string
#  seller_broker_no    :string
#  customer_name       :string
#  quantity            :string
#  rate                :string
#  amount              :string
#  stock_commission    :string
#  bank_deposit        :string
#  transaction_date    :string
#  transaction_bs_date :string
#  fiscal_year         :string
#  nepse_code          :string
#

class Mandala::TempDailyTransaction < ActiveRecord::Base
  self.table_name = "temp_daily_transaction"
end
