# == Schema Information
#
# Table name: commission_rate
#
#  id                :integer          not null, primary key
#  un_id             :string
#  amount_below      :string
#  amount_above      :string
#  rate              :string
#  commission_amount :string
#

class Mandala::CommissionRate < ActiveRecord::Base
  self.table_name = "commission_rate"
end
