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

class ShareTransaction < ApplicationRecord
  # include Auditable
  include CommissionModule
  extend FiscalYearModule
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
  validates :contract_no, uniqueness: { scope: [:transaction_type] }


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
          :by_transaction_type_closeouts,
          :by_isin_id_closeouts,
          :by_other_broker_number_closeouts
      ]
  )

  enum transaction_type: [:buying, :selling, :unknown]
  enum transaction_cancel_status: [:no_deal_cancel, :deal_cancel_pending, :deal_cancel_complete]

  scope :find_by_date, -> (date) { where(
      :date => date.beginning_of_day..date.end_of_day)
  }
  scope :find_by_date_range, -> (date_from, date_to) { where(
      :date => date_from.beginning_of_day..date_to.end_of_day)
  }
  scope :by_date, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    not_cancelled.where(:date => date_ad.beginning_of_day..date_ad.end_of_day)
  }
  scope :by_date_from, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    not_cancelled.where('share_transactions.date >= ?', date_ad.beginning_of_day)
  }
  scope :by_date_to, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    not_cancelled.where('share_transactions.date <= ?', date_ad.end_of_day)
  }
  scope :by_transaction_type, lambda { |type|
    not_cancelled.where(:transaction_type => ShareTransaction.transaction_types[type])
  }
  scope :by_transaction_cancel_status, lambda { |status|
    if status == 'deal_cancel_complete'
      where(:transaction_cancel_status => ShareTransaction.transaction_cancel_statuses[status])
    end
  }
  # current_branch_id = selected_branch_id
  scope :by_branch, ->(branch_id) do
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
      when /^isin_info/
        not_cancelled.order("isin_infos.company #{ direction }")
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
    with_closeout.where('share_transactions.date>= ?', date_ad.beginning_of_day)
  }
  scope :by_date_to_closeouts, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    with_closeout.where('share_transactions.date<= ?', date_ad.end_of_day)
  }
  scope :by_client_id_closeouts, -> (id) { with_closeout.where(client_account_id: id) }
  scope :by_isin_id_closeouts, -> (id) { with_closeout.where(isin_info_id: id) }

  scope :by_transaction_type_closeouts, lambda { |type|
    with_closeout.where(:transaction_type => ShareTransaction.transaction_types[type])
  }
  scope :by_other_broker_number_closeouts, ->(number) {
    with_closeout.where("? = CASE WHEN share_transactions.transaction_type = 1 THEN share_transactions.buyer ELSE share_transactions.seller END", number)
  }
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
  scope :settled_with_bill, lambda{ where.not(bill_id: nil)}
  scope :settled, lambda{ where.not(settlement_id: nil)}
  scope :cgt_gt_zero, lambda{ where('cgt > ?', 0.0)}

  scope :for_cgt, ->(fy_code) do
    includes(:bill).selling.settled_with_bill.cgt_gt_zero.where('bills.fy_code =  ?', fy_code).references(:bills)
  end


  # used for bill ( it eradicates only with deal cancelled not the closeout onces)
  # data needs to be hidden from client for deal cancel only as it happens between brokers.
  scope :not_cancelled_for_bill, -> { where(deleted_at: nil) }

  scope :cancelled, -> { where.not(deleted_at: nil) }
  scope :without_chalan, -> { where(deleted_at: nil).where.not(quantity: 0).where(nepse_chalan_id: nil) }
  # deleted transactions fall under deal cancel
  scope :with_closeout, -> { where(deleted_at: nil).where.not(closeout_amount: 0.0)}
  scope :above_threshold, ->{ not_cancelled.where("net_amount >= ?", 1000000) }



  scope :weighted_average, lambda{|col, quantity_col = :quantity|
    select("share_transactions.isin_info_id").
      select(<<-EOQ)
      (CASE WHEN SUM(#{quantity_col}) = 0 THEN 0
            ELSE SUM(#{col} * #{quantity_col}) / SUM(#{quantity_col})
       END) AS wa_#{col},
      sum(#{quantity_col}) as quantity,
      sum(tds) as tds,
      sum(nepse_commission) as nepse_commission,
      sum(commission_amount) as commission_amount,
      sum(dp_fee) as dp_fee,
      sum(bank_deposit) as bank_deposit,
      sum(amount_receivable) as amount_receivable,
      sum(closeout_amount) as closeout_amount
    EOQ
  }

  after_commit :update_inventory, on: :create

  def update_inventory
    ShareInventoryJob.perform_later(client_account_id, isin_info_id, quantity, updater_id, buying?, false)
  end

  def do_as_per_params (params)
    # TODO
  end

  def as_json(options={})
    super.as_json(options).merge({date_bs: self.class.ad_to_bs_string_public(date), :isin_info => isin_info, client_account: client_account.as_json})
  end


  def available_balancing_transactions
    self.class.where('date > ?', self.date).where(isin_info_id: self.isin_info_id, client_account_id: self.client_account_id, closeout_amount: 0, transaction_type: self.class.transaction_types[:buying])
  end
  #
  # Returns a hash with share quantity flows of an isin from the search scope that is provided in the `filterrific` ParamSet.
  # The passed in isin_info_id is bind with `by_isin_id filter, which might or might not have been initially set to some value in filterrific's search scope.
  #
  def self.quantity_flows_for_isin(filterrific, isin_info_id = nil)
    # Assign `by_isin_id` filter as the isin_info_id method argument.
    filterrific.by_isin_id = isin_info_id if isin_info_id
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

  def self.securities_flows(tenant_broker_id, isin_id, date_bs, date_from_bs, date_to_bs, branch_id )
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
    if date_from_bs.present? || date_to_bs.present?
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

  def self.sebo_report isin_id, date_from_bs, date_to_bs, branch_id, selected_fy_code
    ar_connection = ActiveRecord::Base.connection
    where_conditions =  []

    if isin_id.present?
      isin_id = ar_connection.quote(isin_id)
      where_conditions << "isin_info_id = #{isin_id}"
    end

    if date_from_bs.present? || date_to_bs.present?
      date_from_ad = bs_to_ad(date_from_bs)
      date_to_ad = bs_to_ad(date_to_bs)
      where_conditions << "(share_transactions.date BETWEEN '#{date_from_ad}' AND '#{date_to_ad}')"
    else
      date_from_ad = fiscal_year_first_day(selected_fy_code)
      date_to_ad = fiscal_year_last_day(selected_fy_code)
      where_conditions << "(share_transactions.date BETWEEN '#{date_from_ad}' AND '#{date_to_ad}')"
    end

    if branch_id != 0
      where_conditions << "(branch_id = #{branch_id})"
    end

    where_condition_str = "#{where_conditions.join(" AND ")}"
    # if where_conditions.present?
    #   # where_condition_str = "#{where_conditions.join(" AND ")} AND client_accounts.branch_id = #{UserSession.selected_branch_id}"
    #   # where_condition_str = "client_accounts.branch_id = #{UserSession.selected_branch_id}"
    #   client_ids = ClientAccount.where(branch_id: UserSession.selected_branch_id).pluck(:id)
    # else
    #   # where_condition_str = "client_accounts.branch_id = #{UserSession.selected_branch_id}"
    # end

    # for buy deal cancel and closeout not considered
    # for sell closeout considered but not deal cancel

    ShareTransaction
      .where('(quantity <> 0 AND transaction_type = 0) OR (transaction_type = 1 AND transaction_cancel_status <> 2)')
      .includes(:isin_info).where(where_condition_str)
      .group(:isin_info_id)
      .select(
        :isin_info_id,
        "COUNT(CASE WHEN transaction_type = 0 THEN 1 ELSE NULL END) as buy_transaction_count",
      "SUM(CASE WHEN transaction_type = 0 THEN quantity ELSE 0 END) as buy_quantity",
      "SUM(CASE WHEN transaction_type = 0 THEN share_amount ELSE 0 END ) as buying_amount",
      "SUM(CASE WHEN transaction_type = 0 THEN sebo ELSE 0 END ) as buy_sebo_comm",
      "SUM(CASE WHEN transaction_type = 0 THEN commission_amount ELSE 0 END ) as buy_comm_amount",
      "SUM(CASE WHEN transaction_type = 0 THEN nepse_commission ELSE 0 END ) as buy_nepse_comm",
      "SUM(CASE WHEN transaction_type = 0 THEN tds ELSE 0 END ) as buy_tds",
      "SUM(CASE WHEN transaction_type = 0 THEN bank_deposit ELSE 0 END ) as amount_to_nepse",
      "COUNT(CASE WHEN transaction_type = 1 THEN 1 ELSE NULL END) as selling_transaction_count",
      "SUM(CASE WHEN transaction_type = 1 THEN raw_quantity ELSE 0 END ) as selling_quantity",
      "SUM(CASE WHEN transaction_type = 1 THEN share_amount ELSE 0 END ) as selling_amount",
      "SUM(CASE WHEN transaction_type = 1 THEN commission_amount ELSE 0 END ) as selling_comm_amount",
      "SUM(CASE WHEN transaction_type = 1 THEN tds ELSE 0 END ) as selling_tds",
      "SUM(CASE WHEN transaction_type = 1 THEN sebo ELSE 0 END ) as selling_sebo_comm",
      "SUM(CASE WHEN transaction_type = 1 THEN nepse_commission ELSE 0 END ) as selling_nepse_comm",
      "SUM(cgt) as total_cgt",
      "SUM(CASE WHEN transaction_type = 1 THEN bank_deposit ELSE 0 END) as amount_from_nepse",
      "COUNT(*) as total_transaction_count",
      "SUM(raw_quantity) as total_quantity",
      "SUM(share_amount * (case transaction_type when 0 then 1 else 0 end)) as buy_sum",
        "SUM(share_amount) as total_amount",
        "SUM(share_amount * (case transaction_type when 1 then 1 else 0 end)) as sell_sum")
  end

  def self.threshold_report date_bs, client_account_id, date_from_bs, date_to_bs, selected_fy_code
    ar_connection = ActiveRecord::Base.connection
    where_conditions =  []

    if client_account_id.present?
      client_account_id = ar_connection.quote(client_account_id)
      where_conditions << "client_account_id = #{client_account_id}"
    end

    if date_bs.present?
      date_ad = bs_to_ad(date_bs)
      where_conditions << "(share_transactions.date = '#{date_ad}')"
    end

    if date_from_bs.present? || date_to_bs.present?
      date_from_ad = bs_to_ad(date_from_bs)
      date_to_ad = bs_to_ad(date_to_bs)
      where_conditions << "(share_transactions.date BETWEEN '#{date_from_ad}' AND '#{date_to_ad}')"
    else
      date_from_ad = fiscal_year_first_day(selected_fy_code)
      date_to_ad = fiscal_year_last_day(selected_fy_code)
      where_conditions << "(share_transactions.date BETWEEN '#{date_from_ad}' AND '#{date_to_ad}')"
    end

    where_condition_str = "#{where_conditions.join(" AND ")}"
    # ShareTransaction.includes(:client_account).where(where_condition_str).limit(10)

    @share_transactions = ShareTransaction
      .where(where_condition_str)
      .includes(:client_account)
      .joins("inner join client_accounts on client_accounts.id = client_account_id")
      .group(:client_account_id, :date)
      .select(
       :client_account_id,
       :date,
       "array_agg(transaction_type) as grouped_types",
       "SUM(share_amount) as grouped_amount",
      ).having("SUM(share_amount) > 1000000")
        .order('max(client_accounts.name) asc')
  end

  def unique_types
    if grouped_types
      grouped_types.uniq.sort.map{|x| ShareTransaction.transaction_types.keys[x].titleize}.join(', ')
    end
  end


  def self.where_conditions_for_commission_report client_id, date_from_bs, date_to_bs, selected_fy_code
    where_conditions =  []
    ar_connection = ActiveRecord::Base.connection
    if client_id.present?
      client_id = ar_connection.quote(client_id)
      where_conditions << "client_account_id = #{client_id}"
    end

    if date_from_bs.present? || date_to_bs.present?
      date_from_ad = bs_to_ad(date_from_bs)
      date_to_ad = bs_to_ad(date_to_bs)
      where_conditions << "(share_transactions.date BETWEEN '#{date_from_ad}' AND '#{date_to_ad}')"
    else
      date_from_ad = fiscal_year_first_day(selected_fy_code)
      date_to_ad = fiscal_year_last_day(selected_fy_code)
      where_conditions << "(share_transactions.date BETWEEN '#{date_from_ad}' AND '#{date_to_ad}')"
    end
    where_conditions
  end

  def self.commission_report client_id, date_from_bs, date_to_bs, selected_fy_code

    where_conditions =  where_conditions_for_commission_report client_id, date_from_bs, date_to_bs, selected_fy_code
    where_condition_str = "#{where_conditions.join(" AND ")}"
    ShareTransaction.includes(:client_account).where(where_condition_str).group(:client_account_id).select(
        :client_account_id,
        "COUNT(transaction_type) as transaction_count",
        "SUM(raw_quantity) as total_quantity",
        "SUM(share_amount) as total_amount",
        "SUM(commission_amount-nepse_commission) as total_commission_amount").order("total_commission_amount DESC")
  end

  def self.total_count_for_commission_report client_id, date_from_bs, date_to_bs, selected_fy_code
    where_conditions =  where_conditions_for_commission_report client_id, date_from_bs, date_to_bs, selected_fy_code
    where_condition_str = "#{where_conditions.join(" AND ")}"
    ShareTransaction.where(where_condition_str).pluck(:client_account_id).uniq.count
  end

  # instead of deleting, indicate the user requested a delete & timestamp it
  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  def soft_undelete
    update_attribute(:deleted_at, nil)
  end


  # used for the provisional only
  # not used for the base price calculation
  def update_with_base_price(params)
    self.update(params)
    self.calculate_cgt
    self
  end

  # used for the provisional only
  # not used for the base price calculation
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
    # [
    #     ['Buying', 'buying'],
    #     ['Selling', 'selling'],
    # ]
    ShareTransaction.transaction_types.except(:unknown).map{|v,i| [v.titleize,v]}
  end


  def closeout_settled?
    closeout_settled
  end

  def stock_commission_amount
    commission_amount * nepse_commission_rate(date)
  end

  def counter_broker
    self.buying? ? self.seller : self.buyer
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
    elsif purchase_price/quantity == 100
       calculated_base_price = 100
    else
      commission_group = isin_info.commission_group
      commission_rates_desc = get_commission_rate_array_for_date(date, commission_group)
      commission_info = get_commission_info_with_detail(date, commission_group)
      possible_commission_rate = get_commission_rate(purchase_price, commission_info)
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
        commission_rate_for_possible_share_amount = get_commission_rate(possible_share_amount, commission_info)
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
