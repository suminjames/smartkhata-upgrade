# == Schema Information
#
# Table name: temp_name_transfer
#
#  id             :integer          not null, primary key
#  transaction_no :string
#  quantity       :string
#

class Mandala::TempNameTransfer < ActiveRecord::Base
  self.table_name = "temp_name_transfer"
end
