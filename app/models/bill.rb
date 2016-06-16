# == Schema Information
#
# Table name: bills
#
#  id                :integer          not null, primary key
#  bill_number       :integer
#  client_name       :string
#  net_amount        :decimal(15, 4)   default("0")
#  balance_to_pay    :decimal(15, 4)   default("0")
#  bill_type         :integer
#  status            :integer          default("0")
#  special_case      :integer          default("0")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  fy_code           :integer
#  date              :date
#  date_bs           :string
#  settlement_date   :date
#  client_account_id :integer
#  creator_id        :integer
#  updater_id        :integer
#  branch_id         :integer
#


class Bill < ActiveRecord::Base
  include CustomDateModule

  # added the updater and creater user tracking
  include ::Models::UpdaterWithBranchFycode

  # has_many :share_transactions, -> { where deleted_at: nil} #return all that are not cancelled (and therefore not have a deleted_at record)
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

  # # Bill cancel Status
  # #  - none : regular
  # #  - deal_cancel: Deal cancelled for atleast one of the share transactions
  enum special_case: [:regular, :has_deal_cancelled, :has_closeout]

  attr_accessor :provisional_base_price

  validates_presence_of :client_account, :date_bs

  # not settled bill will not account provisional bill
  scope :find_not_settled, -> { where(status: [statuses[:pending], statuses[:partial]]) }
  scope :find_by_bill_type, -> (type) { where(bill_type: bill_types[:"#{type}"]) }


  #  TODO: Implement multi-name search
  scope :find_by_client_name, -> (name) { where("client_name ILIKE ?", "%#{name}%").order(:status) }
  scope :find_by_bill_number, -> (number) { where("bill_number" => "#{number}") }
  scope :find_by_date, -> (date) { where(:date => date.beginning_of_day..date.end_of_day) }
  scope :find_by_date_range, -> (date_from, date_to) { where(:date => date_from.beginning_of_day..date_to.end_of_day) }
  scope :find_by_client_id, -> (id) { where(client_account_id: id).order(:status) }
  scope :find_not_settled_by_client_account_id, -> (id) { find_not_settled.where("client_account_id" => id) }

  # as these are used for accounting purpose do not consider provisional
  scope :requiring_processing, -> { where(status: ["pending", "partial"]) }
  scope :requiring_receive, -> { where(status: [Bill.statuses[:pending], Bill.statuses[:partial]], bill_type: Bill.bill_types[:purchase]) }
  scope :requiring_payment, -> { where(status: [Bill.statuses[:pending], Bill.statuses[:partial]], bill_type: Bill.bill_types[:sales]) }


  before_save :process_bill

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
    return self.share_transactions.not_cancelled_for_bill.sum(:dp_fee);
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
    return ClientAccount.find(self.client_account_id)
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
    self.bill_type = :sales
    self.status = :provisional
    self.bill_number = Bill.new_bill_number(get_fy_code)
    self
  end


  # get new bill number
  def self.new_bill_number(fy_code)
    bill = Bill.where(fy_code: fy_code).last
    # initialize the bill with 1 if no bill is present
    if bill.nil?
      1
    else
      # increment the bill number
      bill.bill_number + 1
    end
  end


  private
  def process_bill
    self.date ||= Time.now
    self.date_bs ||= ad_to_bs_string(self.date)
    self.client_name ||= self.client_account.name
  end


end
