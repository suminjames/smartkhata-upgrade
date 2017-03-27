# == Schema Information
#
# Table name: order_request_details
#
#  id               :integer          not null, primary key
#  quantity         :integer
#  rate             :integer
#  status           :integer          default(0)
#  isin_info_id     :integer
#  order_request_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class OrderRequestDetail < ActiveRecord::Base
  belongs_to :isin_info
  belongs_to :order_request

  validates_presence_of :isin_info, :rate, :quantity


  enum status: [:pending, :acknowledged, :partial, :completed, :deleted, :cancelled]
  delegate :company, to: :isin_info
  delegate :client_account, to: :order_request

  scope :todays_order, -> { where(created_at: Time.now.beginning_of_day..Time.now.end_of_day)}

  def can_be_updated?
    self.pending?
  end

  def soft_delete
    update_attribute(:status, statuses[:deleted])
  end

end
