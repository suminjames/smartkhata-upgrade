class Mandala::VoucherDetail < ActiveRecord::Base
  self.table_name = "voucher_detail"
  # attr_accessor :ac_name

  def self.with_ac_code
    Mandala::VoucherDetail.joins('INNER JOIN chart_of_account  ON chart_of_account.ac_code = voucher_detail.ac_code').select("voucher_detail.*, chart_of_account.ac_name as ac_name")
  end
end