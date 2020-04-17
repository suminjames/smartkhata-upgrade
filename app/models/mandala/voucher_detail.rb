# == Schema Information
#
# Table name: voucher_detail
#
#  id                :integer          not null, primary key
#  voucher_no        :string
#  voucher_code      :string
#  ac_code           :string
#  sub_code          :string
#  particulars       :string
#  currency_code     :string
#  amount            :string
#  conversion_rate   :string
#  nrs_amount        :string
#  transaction_type  :string
#  cost_revenue_code :string
#  invoice_no        :string
#  vou_period        :string
#  against_ac_code   :string
#  against_sub_code  :string
#  cheque_no         :string
#  fiscal_year       :string
#  serial_no         :string
#

class Mandala::VoucherDetail < ApplicationRecord
  self.table_name = "voucher_detail"
  # attr_accessor :ac_name

  def self.with_ac_code
    Mandala::VoucherDetail.joins('INNER JOIN chart_of_account  ON chart_of_account.ac_code = voucher_detail.ac_code').select("voucher_detail.*, chart_of_account.ac_name as ac_name")
  end
end
