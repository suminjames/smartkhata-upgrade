# == Schema Information
#
# Table name: order_requests
#
#  id                :integer          not null, primary key
#  client_account_id :integer
#  date_bs           :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class OrderRequest < ApplicationRecord
  belongs_to :client_account
  has_many :order_request_details
  has_many :isin_infos, through: :order_request_details

  has_one :ledger, through: :client_account

  accepts_nested_attributes_for :order_request_details
end
