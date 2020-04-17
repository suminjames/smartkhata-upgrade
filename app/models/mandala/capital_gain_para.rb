# == Schema Information
#
# Table name: capital_gain_para
#
#  id         :integer          not null, primary key
#  group_code :string
#  group_name :string
#  remarks    :string
#

class Mandala::CapitalGainPara < ApplicationRecord
  self.table_name = "capital_gain_para"
end
