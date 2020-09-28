# == Schema Information
#
# Table name: supplier_bill_detail
#
#  id          :integer          not null, primary key
#  bill_no     :string
#  particular  :string
#  quantity    :string
#  unit_price  :string
#  total_price :string
#  remarks     :string
#

class Mandala::SupplierBillDetail < ApplicationRecord
  self.table_name = "supplier_bill_detail"
end
