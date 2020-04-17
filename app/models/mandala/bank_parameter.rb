# == Schema Information
#
# Table name: bank_parameter
#
#  id        :integer          not null, primary key
#  bank_code :string
#  bank_name :string
#  ac_code   :string
#  remarks   :string
#

class Mandala::BankParameter < ApplicationRecord
  self.table_name = "bank_parameter"
end
