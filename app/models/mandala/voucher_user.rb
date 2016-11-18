# == Schema Information
#
# Table name: voucher_user
#
#  id           :integer          not null, primary key
#  voucher_code :string
#  voucher_name :string
#  voucher_type :string
#  user_code    :string
#  status       :string
#

class Mandala::VoucherUser < ActiveRecord::Base
  self.table_name = "voucher_user"
end
