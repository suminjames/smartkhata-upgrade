# == Schema Information
#
# Table name: share_receipt
#
#  id            :integer          not null, primary key
#  receipt_no    :string
#  received_date :string
#  customer_code :string
#  received_by   :string
#  fiscal_year   :string
#  remarks       :string
#

class Mandala::ShareReceipt < ActiveRecord::Base
  self.table_name = "share_receipt"
end
