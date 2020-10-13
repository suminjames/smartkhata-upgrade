# == Schema Information
#
# Table name: customer_child_info
#
#  id                 :integer          not null, primary key
#  customer_code      :string
#  child_name         :string
#  relation           :string
#  child_dob          :string
#  child_dob_bs       :string
#  child_birth_reg_no :string
#  issued_place       :string
#

class Mandala::CustomerChildInfo < ApplicationRecord
  self.table_name = "customer_child_info"
end
