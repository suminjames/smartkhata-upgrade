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

  include CustomDateModule
  extend CustomDateModule

  belongs_to :isin_info
  belongs_to :order_request

  validates_presence_of :isin_info, :rate, :quantity


  enum status: [:pending, :acknowledged, :partial, :completed, :cancelled]
  delegate :company, to: :isin_info
  delegate :client_account, to: :order_request

  scope :todays_order, -> { where(created_at: Time.now.beginning_of_day..Time.now.end_of_day)}

  def can_be_updated?
    self.pending?
  end

  def soft_delete
    update_attribute(:status, self.class.statuses[:cancelled])
  end


  filterrific(
      default_filter_params: { sorted_by: 'created_at_desc' },
      available_filters: [
          :sorted_by,
          :with_company_id,
          :with_date,
          :with_status
      ]
  )

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^created_at_desc/
        order("order_request_details.created_at #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_date, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where(:created_at=> date_ad.beginning_of_day..date_ad.end_of_day)
  }
  scope :with_company_id, -> (id) { where(isin_info_id: id) }
  scope :with_status, -> (status) { where(status: status ) }
end
