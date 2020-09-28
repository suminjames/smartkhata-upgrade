# == Schema Information
#
# Table name: supplier_ledger
#
#  id               :integer          not null, primary key
#  supplier_id      :string
#  bill_no          :string
#  settlement_date  :string
#  particulars      :string
#  entered_by       :string
#  entered_date     :string
#  fiscal_year      :string
#  transaction_date :string
#  dr_amount        :string
#  cr_amount        :string
#  transaction_id   :string
#  slip_no          :string
#  slip_type        :string
#  settlement_tag   :string
#  remarks          :string
#  quantity         :string
#

class Mandala::SupplierLedger < ActiveRecord::Base
  self.table_name = "supplier_ledger"
end
