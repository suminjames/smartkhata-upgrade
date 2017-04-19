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
#  settlement_date           :date
#  closeout_settled          :boolean          default(FALSE)
#

class ShareTransaction < ActiveRecord::Base
  include Auditable
  include CommissionModule
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

  # before_update :calculate_cgt
  validates :base_price, numericality: true

  filterrific(
      default_filter_params: { sorted_by: 'date_asc' },
      available_filters: [
          :sorted_by,
          :by_date,
          :by_date_from,
          :by_date_to,
          :by_client_id,
          :by_isin_id,
          :by_transaction_type,
          :by_transaction_cancel_status,
          :above_threshold,
          # for close outs
          :sorted_by_closeouts,
          :by_date_closeouts,
          :by_date_from_closeouts,
          :by_date_to_closeouts,
          :by_client_id_closeouts,
          :by_isin_id_closeouts,
      ]
  )

  enum transaction_type: [:buying, :selling, :unknown]
  enum transaction_cancel_status: [:no_deal_cancel, :deal_cancel_pending, :deal_cancel_complete]

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
  scope :by_transaction_type, lambda { |type|
    not_cancelled.where(:transaction_type => ShareTransaction.transaction_types[type])
  }
  scope :by_transaction_cancel_status, lambda { |status|
    if status == 'deal_cancel_complete'
      where(:transaction_cancel_status => ShareTransaction.transaction_cancel_statuses[status])
    end
  }

  scope :by_branch, ->(branch_id = UserSession.selected_branch_id) do
    includes(:client_account).where(client_accounts: {branch_id: branch_id}) unless branch_id == 0
  end

  scope :by_client_id, -> (id) { not_cancelled.where(client_account_id: id) }
  scope :by_isin_id, -> (id) { not_cancelled.where(isin_info_id: id) }

  # does not show transactions with full closeout
  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^id/
        not_cancelled.order("share_transactions.id #{ direction }")
      when /^date/
        not_cancelled.order("share_transactions.date #{ direction }")
      when /^close_out/
        order("share_transactions.date asc")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }


  # for closeouts
  scope :by_date_closeouts, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    with_closeout.where(:date=> date_ad.beginning_of_day..date_ad.end_of_day)
  }
  scope :by_date_from_closeouts, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    with_closeout.where('date>= ?', date_ad.beginning_of_day)
  }
  scope :by_date_to_closeouts, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    with_closeout.where('date<= ?', date_ad.end_of_day)
  }
  scope :by_client_id_closeouts, -> (id) { with_closeout.where(client_account_id: id) }
  scope :by_isin_id_closeouts, -> (id) { with_closeout.where(isin_info_id: id) }


  scope :sorted_by_closeouts, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^id/
        with_closeout.order("share_transactions.id #{ direction }")
      when /^date/
        with_closeout.order("share_transactions.date #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }
  # used for inventory (it selects only those which are not cancelled and have more than 1 share quantity)
  # deleted at is set for deal cancelled and quantity 0 is the case where closeout occurs
  scope :not_cancelled, -> { where(deleted_at: nil).where.not(quantity: 0) }
  scope :settled, lambda{ where.not(settlement_id: nil)}

  # used for bill ( it eradicates only with deal cancelled not the closeout onces)
  # data needs to be hidden from client for deal cancel only as it happens between brokers.
  scope :not_cancelled_for_bill, -> { where(deleted_at: nil) }

  scope :cancelled, -> { where.not(deleted_at: nil) }
  scope :without_chalan, -> { where(deleted_at: nil).where.not(quantity: 0).where(nepse_chalan_id: nil) }
  # deleted transactions fall under deal cancel
  scope :with_closeout, -> { where(deleted_at: nil).where.not(closeout_amount: 0.0)}
  scope :above_threshold, ->{ not_cancelled.where("net_amount >= ?", 1000000) }

  def do_as_per_params (params)
    # TODO
  end

  def as_json(options={})
    super.as_json(options).merge({:isin_info => isin_info, client_account: client_account.as_json})

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
    balance_share_amount = 0
    share_transactions.each do |st|
      if st.buying?
        total_in_sum += st.quantity
        balance_share_amount += st.share_amount
      elsif st.selling?
        total_out_sum += st.quantity
        balance_share_amount -= st.share_amount
      end
    end
    balance_sum = total_in_sum - total_out_sum
    {
        :total_in_sum => total_in_sum,
        :total_out_sum => total_out_sum,
        :balance_sum => balance_sum,
        :balance_share_amount => balance_share_amount
    }
  end

  def self.securities_flows(tenant_broker_id, isin_id, date_bs, date_from_bs, date_to_bs, branch_id = UserSession.selected_branch_id)
    ar_connection = ActiveRecord::Base.connection
    where_conditions =  []

    if isin_id.present?
      isin_id = ar_connection.quote(isin_id)
      where_conditions << "isin_info_id = #{isin_id}"
    end
    if date_bs.present?
      date_ad = bs_to_ad(date_bs)
      where_conditions << "date = '#{date_ad}'"
    end
    if date_from_bs.present? && date_to_bs.present?
      date_from_ad = bs_to_ad(date_from_bs)
      date_to_ad = bs_to_ad(date_to_bs)
      where_conditions << "(date BETWEEN '#{date_from_ad}' AND '#{date_to_ad}')"
    end

    if where_conditions.present?
      where_condition_str = "WHERE #{where_conditions.join(" AND ")} AND client_accounts.branch_id = #{branch_id}"
    else
      where_condition_str = "WHERE client_accounts.branch_id = #{branch_id}"
    end

    tenant_broker_id = ar_connection.quote(tenant_broker_id)
    query = "
      SELECT
        isin_info_id,
        SUM( CASE WHEN buyer = #{tenant_broker_id} THEN quantity ELSE 0 END ) AS quantity_in_sum,
        SUM( CASE WHEN seller = #{tenant_broker_id} THEN quantity ELSE 0 END ) AS quantity_out_sum
      FROM
        share_transactions
      INNER JOIN
        client_accounts on client_accounts.id = share_transactions.client_account_id
      #{where_condition_str}
      GROUP BY
        isin_info_id
      ORDER BY
        isin_info_id
      "
    pg_result = ar_connection.execute(query)
    result_arr = []
    pg_result.each do |rec|
      rec["quantity_balance"] = rec["quantity_in_sum"].to_i - rec["quantity_out_sum"].to_i
      result_arr << rec
    end
    result_arr
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
      # self.cgt = (self.share_rate - self.base_price) * tax_rate * self.quantity
      cgt_var = (self.share_rate - self.base_price) * tax_rate * self.quantity
      if cgt_var < 0
        cgt_var = 0
      end
      self.cgt = cgt_var
      self.net_amount = self.net_amount - old_cgt + self.cgt
    end
  end

  def deal_cancelled
    self.deleted_at.present?
  end

  def self.options_for_isin_select
    IsinInfo.all.order(:isin)
  end

  def self.options_for_transaction_type_select
    [
        ['Buying', 'buying'],
        ['Selling', 'selling'],
    ]
  end


  def closeout_settled?
    closeout_settled
  end

  def stock_commission_amount
    commission_amount * nepse_commission_rate(date)
  end

  #
  # Calculation notes:
  # bp = > base price, pp => purchase price, x => commission rate(or amount if flat_25)
  #
  # bp + x% of bp = pp
  # ie, bp * ( x + 100 ) / 100 = pp
  #   bp, x -> unknown
  #   x -> one of the commission percentages
  #   -> estimated from pp
  # bp * quantity => (might be) share_amount
  #
  # -check for correctness
  #  -by comparing x with commission percentage of (might be) share_amount
  #    -if not equal,
  #        -go down to lower tier percentage
  #  -only two level checking should be sufficient
  #   -this is to check for those prices which fall (just) above a range group
  #
  def calculate_base_price
    calculated_base_price = nil
    if (buying? || settlement_id.blank? || quantity == 0 || purchase_price == 0)
      calculated_base_price = 0.0
    else
      commission_rates_desc = get_commission_rate_array_for_date(date)
      possible_commission_rate = get_commission_rate(purchase_price, get_commission_info_with_detail(date))
      index_of_possible_commission_rate = commission_rates_desc.index(possible_commission_rate)
      # Remove unwanted commission rate values other than the possible one.
      # The actual commission rate is bigger than or equal to possible commission rate.
      # Check for only two levels of commission rates, which should be sufficient for the calculation.
      from_index = index_of_possible_commission_rate == 0 ? 0 : (index_of_possible_commission_rate - 1)
      to_index = index_of_possible_commission_rate
      commission_rates_desc_snipped = commission_rates_desc[from_index..to_index]
      commission_rates_desc_snipped.reverse.each do |commission_rate|
        if commission_rate.to_s.include?('flat_')
          possible_base_price = purchase_price - commission_rate.split("_")[1].to_f
        else
          possible_base_price = 100.0 * purchase_price / (commission_rate + 100.0)
        end
        # possible_share_amount = possible_base_price * quantity
        possible_share_amount = possible_base_price
        commission_rate_for_possible_share_amount = get_commission_rate(possible_share_amount, get_commission_info_with_detail(date))
        if commission_rate == commission_rate_for_possible_share_amount
          calculated_base_price = possible_base_price
          # The calculate_base_price (above) to this point is actually for the whole transaction, and not a unit of share,
          # very similar to purchase price.
          calculated_base_price = calculated_base_price / quantity
          break
        end
      end
    end
    calculated_base_price.try(:to_i)
  end



end
