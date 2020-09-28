# == Schema Information
#
# Table name: supplier_bill
#
#  id           :integer          not null, primary key
#  bill_no      :string
#  bill_date    :string
#  manual_no    :string
#  supplier_id  :string
#  prepare_by   :string
#  fiscal_year  :string
#  voucher_no   :string
#  prepared_on  :string
#  voucher_code :string
#  ac_code      :string
#

class Mandala::SupplierBill < ActiveRecord::Base
  self.table_name = "supplier_bill"
end
