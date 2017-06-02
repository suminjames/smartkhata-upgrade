# == Schema Information
#
# Table name: bills
#
#  id                         :integer          not null, primary key
#  bill_number                :integer
#  client_name                :string
#  net_amount                 :decimal(15, 4)   default(0.0)
#  balance_to_pay             :decimal(15, 4)   default(0.0)
#  bill_type                  :integer
#  status                     :integer          default(0)
#  special_case               :integer          default(0)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  fy_code                    :integer
#  date                       :date
#  date_bs                    :string
#  settlement_date            :date
#  client_account_id          :integer
#  creator_id                 :integer
#  updater_id                 :integer
#  branch_id                  :integer
#  nepse_settlement_id        :integer
#  settlement_approval_status :integer          default(0)
#  closeout_charge            :decimal(15, 4)   default(0.0)
#

class Bill < ActiveRecord::Base
  include Auditable

  extend CustomDateModule
  include CustomDateModule

  # added the updater and creater user tracking
  include ::Models::UpdaterWithBranchFycode


  has_many :share_transactions
  belongs_to :client_account
  has_many :isin_infos, through: :share_transactions

  has_and_belongs_to_many :vouchers
  has_many :on_creation, -> { on_creation }, class_name: "BillVoucherAssociation"
  has_many :on_settlement, -> { on_settlement }, class_name: "BillVoucherAssociation"
  has_many :bill_voucher_associations

  has_many :vouchers_on_creation, through: :on_creation, source: :voucher
  has_many :vouchers_on_settlement, through: :on_settlement, source: :voucher
  has_many :vouchers, through: :bill_voucher_associations


  attr_accessor :provisional_base_price

  # validations
  validates_presence_of :client_account

  # callbacks
  before_save :process_bill


  # verify this with views everytime before changing
  # bill index
  # bill show
  enum bill_type: [:purchase, :sales]

  # Bill Status
  # - Pending: No payment has been done.
  # - Partial: Some but not all payment has been done.
  # - Settled: All payment if required ( this includes bills with all share transaction cancelled ) has been done.
  # - Provisional: All the bills that are for view purpose only and have no effect on accounting purpose
  enum status: [:pending, :partial, :settled, :provisional]

  #
  # Settlement Approval Status
  # - incognito : no action by default, bill rejected will also fall under this catagory
  # - PendingApproval: Approval is required
  # - Approved: Bill is approved
  enum settlement_approval_status: [:incognito, :pending_approval, :approved]

  # # Bill cancel Status
  # #  - none : regular
  # #  - deal_cancel: Deal cancelled for atleast one of the share transactions
  enum special_case: [:regular, :has_deal_cancelled, :has_closeout]


  # scope based on the branch and fycode selection
  default_scope do
    if UserSession.selected_branch_id == 0
      where(fy_code: UserSession.selected_fy_code)
    else
      where(branch_id: UserSession.selected_branch_id, fy_code: UserSession.selected_fy_code)
    end
  end
  # not settled bill will not account provisional bill
  scope :find_not_settled, -> { where(status: [statuses[:pending], statuses[:partial]]) }
  scope :by_bill_type, -> (type) { where(bill_type: bill_types[:"#{type}"]) }
  scope :by_bill_status, -> (status) { where(:status => Bill.statuses[status]) }
  scope :find_by_date, -> (date) { where(:date => date.beginning_of_day..date.end_of_day) }
  scope :find_by_date_range, -> (date_from, date_to) { where(:date => date_from.beginning_of_day..date_to.end_of_day) }
  scope :by_client_id, -> (id) { where(client_account_id: id) }
  scope :find_not_settled_by_client_account_id, -> (id) { find_not_settled.where("client_account_id" => id) }
  scope :find_not_settled_by_client_account_ids, -> (ids) { find_not_settled.where("client_account_id" => ids) }

  # as these are used for accounting purpose do not consider provisional
  scope :requiring_processing, -> { where(status: ["pending", "partial"]) }
  scope :requiring_receive, -> { where(status: [Bill.statuses[:pending], Bill.statuses[:partial]], bill_type: Bill.bill_types[:purchase]).order(date: :asc) }
  scope :requiring_payment, -> { where(status: [Bill.statuses[:pending], Bill.statuses[:partial]], bill_type: Bill.bill_types[:sales]).order(date: :asc) }
  scope :with_client_bank_account, ->{ includes(:client_account).where.not(:client_accounts => {bank_account: nil}) }
  scope :with_client_bank_account_and_balance_cr, ->{ includes(client_account: :ledger).where.not(:client_accounts => {bank_account: nil}).where('ledgers.closing_blnc < 0').references(:ledger) }

  scope :for_sales_payment_list, ->{with_balance_cr.requiring_processing}
  scope :for_payment_letter_list, ->{with_balance_cr.requiring_processing}

  # scope :by_bill_number, -> (number) { where("bill_number" => "#{number}") }
  scope :by_bill_number, lambda { |number|
      actual_bill_number = self.strip_fy_code_from_full_bill_number(number)
      where("bill_number" => "#{actual_bill_number}")
  }
  scope :by_date, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where(:date=> date_ad.beginning_of_day..date_ad.end_of_day)
  }
  scope :by_date_from, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('date >= ?', date_ad.beginning_of_day)
  }
  scope :by_date_to, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('date <= ?', date_ad.end_of_day)
  }
  scope :by_bill_age, lambda { |number_of_days|
    reference_date = Date.today - number_of_days.to_i
    where('settlement_date <= ?', reference_date)
  }

  filterrific(
      default_filter_params: { },
      available_filters: [
          :sorted_by,
          :by_client_id,
          :by_bill_number,
          :by_bill_type,
          :by_bill_status,
          :by_bill_age,
          :by_date,
          :by_date_from,
          :by_date_to
      ]
  )

  # TODO(sarojk): Implement other sort options too.
  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^bill_number/
        order("bills.bill_number #{ direction }")
      when /^net_amount/
        order("bills.net_amount #{ direction }")
      when /^age/
        order("bills.settlement_date #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }


  # Returns total share amount from all child share_transactions
  def get_net_share_amount
    return self.share_transactions.not_cancelled_for_bill.sum(:share_amount);
  end

  # Returns total sebo commission from all child share_transactions
  def get_net_sebo_commission
    return self.share_transactions.not_cancelled_for_bill.sum(:sebo);
  end

  # Returns total net commission from all child share_transactions
  def get_net_commission
    return self.share_transactions.not_cancelled_for_bill.sum(:commission_amount);
  end

  # TODO: Implement the method.
  def get_name_transfer_amount
    return 'N/A'
  end

  # Returns total net dp fee
  def get_net_dp_fee
    dp_fee = self.share_transactions.not_cancelled_for_bill.sum(:dp_fee);
    if dp_fee == 0
      dp_fee = 25
    end
    return dp_fee
  end

  # Returns total net cgt
  def get_net_cgt
    return self.share_transactions.not_cancelled_for_bill.sum(:cgt);
  end

  # TODO
  # Returns net amount (either payable or recievable) from all child share_transactions.
  # A bill is either payable or recievable is determined by transaction_type
  def get_net_bill_amount
    #return self.share_transactions.sum(:sebo);
  end

  # Returns client associated to this bill
  def get_client
    return self.client_account
  end

  def make_provisional
    # get the transaction date
    begin
      date_ad = bs_to_ad(self.date_bs)
    rescue
      self.errors[:date_bs] << "Invalid Transaction Date. Date format is YYYY-MM-DD"
      return self
    end
    # get all the share transaction for the day
    share_transactions = ShareTransaction.selling.find_by_date(date_ad).where(client_account_id: self.client_account_id)

    # validates base price and return if error
    if self.provisional_base_price.blank?
      self.errors[:provisional_base_price] << "Invalid Base Price"
      return self
    end

    # make sure there are share transactions for the date
    if share_transactions.size < 1
      self.errors[:date_bs] << "No Sales Transactions Found"
      return self
    end

    processed_transactions = []
    share_transactions.each do |share_transaction|
      if share_transaction.bill_id.present?
        self.errors[:date_bs] << "Sales Bill already Created for this date"
        return self
      end
      share_transaction.base_price = self.provisional_base_price
      share_transaction.calculate_cgt
      share_transaction.net_amount = (share_transaction.raw_quantity * share_transaction.share_rate) - (share_transaction.commission_amount) - share_transaction.dp_fee - share_transaction.cgt - share_transaction.sebo
      share_transaction.save!

      self.share_transactions << share_transaction
      self.net_amount += share_transaction.net_amount
    end
    self.date = date_ad
    self.bill_type = :sales
    self.status = :provisional
    self.bill_number = Bill.new_bill_number(get_fy_code)
    # debugger
    self
  end


  # Returns the age of purchase bill in days.
  def age
    age = nil
    if self.purchase?
      age = (Date.today - self.settlement_date).to_i
    end
    age
  end

  # get new bill number
  def self.new_bill_number(fy_code)
    bill = Bill.unscoped.where(fy_code: fy_code).order('bill_number DESC').first
    # initialize the bill with 1 if no bill is present
    if bill.nil?
      1
    else
      # increment the bill number
      bill.bill_number + 1
    end
  end

  # get the bill number with fy code prepended
  def full_bill_number
    "#{self.fy_code}-#{self.bill_number}"
  end

  # Strips pre-pended fy_code from full bill number
  # Eg: Takes in 7273-1509, returns 1509
  # Even if no fy_code pre-pended, still returns the actual bill number.
  def self.strip_fy_code_from_full_bill_number(full_bill_number)
    full_bill_number ||= ''
    full_bill_number_str = full_bill_number.to_s
    hyphen_index = full_bill_number_str.index('-') || -1
    full_bill_number_str[(hyphen_index + 1)..-1]
  end

  def requires_processing?
   self.pending? || self.partial?
  end

  def self.options_for_bill_age_select
    [
        ["> 1 days", 1],
        ["> 2 days", 2],
        ["> 3 days", 3],
        ["> 1 week", 7],
        ["> 2 week", 14],
        ["> 1 month", 30],
        ["> 3 month", 90],
        ["> 6 month", 180],
        ["> 1 year", 364]
    ]
  end

  def self.options_for_bill_type_select
    [
        ["Purchase", "purchase"],
        ["Sales", "sales"]
    ]
  end

  def self.options_for_bill_status_select
    [
        ['Pending', 'pending'],
        ['Partial', 'partial'],
        ['Settled', 'settled'],
        ['Provisional', 'provisional']
    ]
  end

  def self.options_for_bill_status_select_for_ageing_analysis
    [
        ['Pending', 'pending'],
        ['Partial', 'partial'],
    ]
  end

  def has_incorrect_fy_code?
    true_fy_code = get_fy_code(self.settlement_date)
    return true if true_fy_code != self.fy_code
    false
  end

  private
  def process_bill
    self.date ||= Time.now
    self.date_bs ||= ad_to_bs_string(self.date)
    self.client_name ||= self.client_account.name
  end


end
