# == Schema Information
#
# Table name: voucher_transaction
#
#  id           :integer          not null, primary key
#  voucher_no   :string
#  voucher_code :string
#  fiscal_year  :string
#

class Mandala::VoucherTransaction < ApplicationRecord
  self.table_name = "voucher_transaction"
end
