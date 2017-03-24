# == Schema Information
#
# Table name: order_request_details
#
#  id               :integer          not null, primary key
#  quantity         :integer
#  rate             :integer
#  status           :integer
#  isin_info        :integer
#  order_request_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class OrderRequestDetail < ActiveRecord::Base
  belongs_to :isin_info
  belongs_to :order_request

  validates_presence_of :isin_info, :rate, :quantity
end
