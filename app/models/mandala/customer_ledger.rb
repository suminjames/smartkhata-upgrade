# == Schema Information
#
# Table name: customer_ledger
#
#  id               :integer          not null, primary key
#  customer_code    :string
#  bill_no          :string
#  settlement_date  :string
#  particulars      :string
#  entered_by       :string
#  entered_date     :string
#  fiscal_year      :string
#  transaction_date :string
#  dr_amount        :string
#  cr_amount        :string
#  remarks          :string
#  transaction_id   :string
#  slip_no          :string
#  slip_type        :string
#  bill_type        :string
#  settlement_tag   :string
#

class Mandala::CustomerLedger < ApplicationRecord
  self.table_name = "customer_ledger"
end
