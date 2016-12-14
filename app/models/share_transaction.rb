# == Schema Information
#
# Table name: share_transactions
#
#  id                        :integer          not null, primary key
#  contract_no               :decimal(18, )
#  buyer                     :integer
#  seller                    :integer
#  raw_quantity              :integer
#  quantity                  :integer
#  share_rate                :decimal(10, 4)   default(0.0)
#  share_amount              :decimal(15, 4)   default(0.0)
#  sebo                      :decimal(15, 4)   default(0.0)
#  commission_rate           :string
#  commission_amount         :decimal(15, 4)   default(0.0)
#  dp_fee                    :decimal(15, 4)   default(0.0)
#  cgt                       :decimal(15, 4)   default(0.0)
#  net_amount                :decimal(15, 4)   default(0.0)
#  bank_deposit              :decimal(15, 4)   default(0.0)
#  transaction_type          :integer
#  settlement_id             :decimal(18, )
#  base_price                :decimal(15, 4)   default(0.0)
#  amount_receivable         :decimal(15, 4)   default(0.0)
#  closeout_amount           :decimal(15, 4)   default(0.0)
#  remarks                   :string
#  purchase_price            :decimal(15, 4)   default(0.0)
#  capital_gain              :decimal(15, 4)   default(0.0)
#  adjusted_sell_price       :decimal(15, 4)   default(0.0)
#  date                      :date
#  deleted_at                :date
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  nepse_chalan_id           :integer
#  creator_id                :integer
#  updater_id                :integer
#  branch_id                 :integer
#  voucher_id                :integer
#  bill_id                   :integer
#  client_account_id         :integer
#  isin_info_id              :integer
#  transaction_message_id    :integer
#  transaction_cancel_status :integer          default(0)
#

class ShareTransaction < ActiveRecord::Base
  include Auditable
  extend CustomDateModule

  include ::Models::UpdaterWithBranch
  belongs_to :bill
  belongs_to :voucher
  belongs_to :isin_info
  belongs_to :client_account
  belongs_to :nepse_chalan
  belongs_to :transaction_message

  # many to many association between share transaction and particulars
  # required in case of payment letter
  # TODO(Subas) Make sure if voucher_id is required for share transactions.
  # they can be taken from particulars... a thought
  has_many :on_creation, -> { on_creation }, class_name: "ParticularsShareTransaction"
  has_many :on_settlement, -> { on_settlement }, class_name: "ParticularsShareTransaction"
  has_many :on_payment_by_letter, -> { on_payment_by_letter }, class_name: "ParticularsShareTransaction"
  has_many :particulars_share_transactions
  has_many :particulars_on_creation, through: :on_creation, source: :particular
  has_many :particulars_on_settlement, through: :on_settlement, source: :particular
  has_many :particulars_on_payment_by_letter, through: :on_payment_by_letter, source: :particular
  has_many :particulars, through: :particulars_share_transactions

  filterrific(
      default_filter_params: { sorted_by: 'date_asc' },
      available_filters: [
          :sorted_by,
          :by_date,
          :by_date_from,
          :by_date_to,
          :by_client_id,
          :by_isin_id,
          :by_transaction_cancel_status
      ]
  )

  enum transaction_type: [:buying, :selling, :unknown]
  enum transaction_cancel_status: [:no_deal_cancel, :deal_cancel_pending, :deal_cancel_complete]
  # before_update :calculate_cgt
  validates :base_price, numericality: true

  scope :find_by_date, -> (date) { where(
      :date => date.beginning_of_day..date.end_of_day) }
  scope :find_by_date_range, -> (date_from, date_to) { where(
      :date => date_from.beginning_of_day..date_to.end_of_day) }

  scope :by_date, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    not_cancelled.where(:date=> date_ad.beginning_of_day..date_ad.end_of_day)
  }
  scope :by_date_from, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    not_cancelled.where('date>= ?', date_ad.beginning_of_day)
  }
  scope :by_date_to, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    not_cancelled.where('date<= ?', date_ad.end_of_day)
  }
  scope :by_transaction_cancel_status, lambda { |status|
    if status == 'deal_cancel_complete'
      where(:transaction_cancel_status => ShareTransaction.transaction_cancel_statuses[status])
    end
  }

  scope :by_client_id, -> (id) { not_cancelled.where(client_account_id: id) }
  scope :by_isin_id, -> (id) { not_cancelled.where(isin_info_id: id) }

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^id/
        not_cancelled.order("share_transactions.id #{ direction }")
      when /^date/
        not_cancelled.order("share_transactions.date #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  # used for inventory (it selects only those which are not cancelled and have more than 1 share quantity)
  # deleted at is set for deal cancelled and quantity 0 is the case where closeout occurs
  scope :not_cancelled, -> { where(deleted_at: nil).where.not(quantity: 0) }

  # used for bill ( it eradicates only with deal cancelled not the closeout onces)
  # data needs to be hidden from client for deal cancel only as it happens between brokers.
  scope :not_cancelled_for_bill, -> { where(deleted_at: nil) }

  scope :cancelled, -> { where.not(deleted_at: nil) }
  scope :without_chalan, -> { where(deleted_at: nil).where.not(quantity: 0).where(nepse_chalan_id: nil) }

  scope :above_threshold, ->(date) { not_cancelled.find_by_date(date).where("net_amount >= ?", 1000000) }

  def do_as_per_params (params)
    # TODO
  end

  #
  # Returns a hash with share quantity flows of an isin from the search scope that is provided in the `filterrific` ParamSet.
  # The passed in isin_info_id is bind with `by_isin_id filter, which might or might not have been initially set to some value in filterrific's search scope.
  #
  def self.quantity_flows_for_isin(filterrific, isin_info_id)
    # Assign `by_isin_id` filter as the isin_info_id method argument.
    filterrific.by_isin_id = isin_info_id
    share_transactions = filterrific.find
    total_in_sum = 0
    total_out_sum = 0
    balance_sum = 0
    share_transactions.each_with_index do |st, index|
      if st.buying?
        total_in_sum += st.quantity
      else
        total_out_sum += st.quantity
      end
    end
    balance_sum = total_in_sum - total_out_sum
    {
        :total_in_sum => total_in_sum,
        :total_out_sum => total_out_sum,
        :balance_sum => balance_sum
    }
  end

  # instead of deleting, indicate the user requested a delete & timestamp it
  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  def soft_undelete
    update_attribute(:deleted_at, nil)
  end

  def update_with_base_price(params)
    self.update(params)
    self.calculate_cgt
    self
  end

  def calculate_cgt
    old_cgt = self.cgt
    if self.base_price?
      tax_rate = self.client_account.individual? ? 0.05 : 0.1
      # tax_rate = 0.01
      self.cgt = (self.share_rate - self.base_price) * tax_rate * self.quantity
      self.net_amount = self.net_amount - old_cgt + self.cgt
    end
  end

  def deal_cancelled
    self.deleted_at.present?
  end

  def self.options_for_isin_select
    IsinInfo.all.order(:isin)
  end
end
