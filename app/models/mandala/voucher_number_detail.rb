# == Schema Information
#
# Table name: voucher_number_detail
#
#  id               :integer          not null, primary key
#  no_code          :string
#  part_no          :string
#  character_length :string
#  choice_of_part   :string
#  other_constant   :string
#  number_format    :string
#


class Mandala::VoucherNumberDetail < ApplicationRecord
  self.table_name = "voucher_number_detail"
end
