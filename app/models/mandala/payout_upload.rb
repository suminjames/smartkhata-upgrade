# == Schema Information
#
# Table name: payout_upload
#
#  id                      :integer          not null, primary key
#  transaction_no          :string
#  transaction_type        :string
#  transaction_date        :string
#  company_code            :string
#  quantity                :string
#  rate                    :string
#  nepse_commission        :string
#  sebo_commission         :string
#  tds                     :string
#  capital_gain            :string
#  capital_gain_tax        :string
#  adjusted_purchase_price :string
#  closeout_amount         :string
#  closeout_quantity       :string
#  settlement_id           :string
#  receivable_amount       :string
#

class Mandala::PayoutUpload < ActiveRecord::Base
  self.table_name = "payout_upload"
end
