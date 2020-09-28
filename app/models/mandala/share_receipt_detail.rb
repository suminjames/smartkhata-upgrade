# == Schema Information
#
# Table name: share_receipt_detail
#
#  id                 :integer          not null, primary key
#  receipt_no         :string
#  company_code       :string
#  received_quantity  :string
#  rec_certificate_no :string
#  rec_kitta_no_from  :string
#  rec_kitta_no_to    :string
#  returned_quantity  :string
#  ret_certificate_no :string
#  ret_kitta_no_from  :string
#  ret_kitta_no_to    :string
#  returned_date      :string
#  returned_by        :string
#  fiscal_year        :string
#

class Mandala::ShareReceiptDetail < ActiveRecord::Base
  self.table_name = "share_receipt_detail"
end
