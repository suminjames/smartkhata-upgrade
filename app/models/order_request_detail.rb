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
#  branch_id        :integer
#  fy_code          :integer
#

class OrderRequestDetail < ActiveRecord::Base

  include CustomDateModule
  extend CustomDateModule
  include Auditable
  # added the updater and creater user tracking
  include ::Models::WithBranchFycode


  belongs_to :isin_info
  belongs_to :order_request

  has_one :ledger, through: :order_request
  has_one :client_account, through: :order_request

  validates_presence_of :isin_info, :rate, :quantity


  enum status: [:pending, :acknowledged, :partial, :completed, :cancelled, :rejected]
  delegate :company, to: :isin_info
  delegate :client_account, to: :order_request
  delegate :closing_balance, to: :ledger

  scope :todays_order, -> { where(created_at: Time.now.beginning_of_day..Time.now.end_of_day)}
  scope :client_order, ->(user_id) { includes(:client_account).where(:client_accounts => {user_id: user_id}).references(:client_account) }


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
          :with_client_id,
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
  scope :with_client_id, ->(client_account_id) { includes(:client_account).where(:client_accounts => {id: client_account_id}).references(:client_account) }

  scope :branch_scoped, -> {
    if UserSession.selected_branch_id == 0
      where(fy_code: UserSession.selected_fy_code)
    else
      where(branch_id: UserSession.selected_branch_id, fy_code: UserSession.selected_fy_code)
    end
  }

  def as_json(options={})
    super.as_json(options).merge({:closing_balance => closing_balance, client_name: client_account.name, nepse_code: client_account.nepse_code, company: company })
  end

end
