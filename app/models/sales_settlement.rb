# == Schema Information
#
# Table name: sales_settlements
#
#  id              :integer          not null, primary key
#  settlement_id   :decimal(18, )
#  status          :integer          default("0")
#  settlement_date :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class SalesSettlement < ActiveRecord::Base
  enum status: [:pending, :complete]
end
