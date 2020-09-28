# == Schema Information
#
# Table name: voucher_number_configuration
#
#  id                :integer          not null, primary key
#  no_code           :string
#  voucher_no_format :string
#

class Mandala::VoucherNumberConfiguration < ApplicationRecord
  self.table_name = "voucher_number_configuration"
end
