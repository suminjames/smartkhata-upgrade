# == Schema Information
#
# Table name: voucher_parameter
#
#  id              :integer          not null, primary key
#  voucher_code    :string
#  voucher_name    :string
#  voucher_type    :string
#  dr_ac_code      :string
#  dr_sub_code     :string
#  cr_ac_code      :string
#  cr_sub_code     :string
#  check_dr_code   :string
#  check_cr_code   :string
#  checked_by      :string
#  approved_by     :string
#  authorized_by   :string
#  voucher_no_code :string
#

class Mandala::VoucherParameter < ApplicationRecord
  self.table_name = "voucher_parameter"
end
