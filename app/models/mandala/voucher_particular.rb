# == Schema Information
#
# Table name: voucher_particulars
#
#  id              :integer          not null, primary key
#  bill_no         :string
#  count_shares    :string
#  no_of_shares    :string
#  rate_per_share  :string
#  company_code    :string
#  commission_rate :string
#  fiscal_year     :string
#  transaction_fee :string
#

class Mandala::VoucherParticular < ApplicationRecord
  self.table_name = "voucher_particulars"
end
