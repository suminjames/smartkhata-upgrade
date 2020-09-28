# == Schema Information
#
# Table name: buy_settlement
#
#  id               :integer          not null, primary key
#  transaction_no   :string
#  transaction_type :string
#  transaction_date :string
#  company_code     :string
#  quantity         :string
#  rate             :string
#  nepse_commission :string
#  sebo_commission  :string
#  tds              :string
#  settlement_id    :string
#

class Mandala::BuySettlement < ApplicationRecord
  self.table_name = "buy_settlement"
end
