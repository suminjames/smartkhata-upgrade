# == Schema Information
#
# Table name: order_requests
#
#  id         :integer          not null, primary key
#  date_bs    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OrderRequest < ActiveRecord::Base
  has_many :order_request_details
  accepts_nested_attributes_for :order_request_details
end
