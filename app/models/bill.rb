class Bill < ActiveRecord::Base
  include CustomDateModule
  # added the updater and creater user tracking
  include ::Models::UpdaterWithBranchFycode

  #TODO Now that a bill
  # has_many :share_transactions, -> { where deleted_at: nil} #return all that are not cancelled (and therefore not have a deleted_at record)
  has_many :share_transactions
  belongs_to :client_account
  has_many :isin_infos , through: :share_transactions

  has_and_belongs_to_many :vouchers
  has_many :on_creation, -> { on_creation }, class_name: "BillVoucherRelation"
  has_many :on_settlement, -> { on_settlement }, class_name: "BillVoucherRelation"
  has_many :bill_voucher_relations

  has_many :vouchers_on_creation, through: :on_creation, source: :voucher
  has_many :vouchers_on_settlement, through: :on_settlement, source: :voucher
  has_many :vouchers , through: :bill_voucher_relations
  # has_many :particulars, through: :voucher

  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  # verify this with views everytime before changing
  # bill index
  # bill show
	enum bill_type: [ :purchase, :sales ]

  # Bill Status
  # - Pending: No payment has been done.
  # - Partial: Some but not all payment has been done.
  # - Settled: All payment if required ( this includes bills with all share transaction cancelled ) has been done.
	enum status: [:pending,:partial,:settled]

  # # Bill cancel Status
  # #  - none : Default
  # #  - deal_cancel: Deal cancelled for atleast one of the share transactions
  enum special_case: [:regular, :has_deal_cancelled, :has_closeout]

  scope :find_not_settled, -> { where(status: [statuses[:pending], statuses[:partial]]) }
  scope :find_by_bill_type, -> (type) { where(bill_type: bill_types[:"#{type}"]) }
  #  TODO: Implement multi-name search
  scope :find_by_client_name, -> (name) { where("client_name ILIKE ?", "%#{name}%").order(:status) }
  scope :find_by_bill_number, -> (number) { where("bill_number" => "#{number}") }
  scope :find_by_date, -> (date) { where(
    :date => date.beginning_of_day..date.end_of_day) }
  scope :find_by_date_range, -> (date_from, date_to) { where(
    :date => date_from.beginning_of_day..date_to.end_of_day) }
  scope :find_by_client_account_id, -> (id) { find_not_settled.where("client_account_id" => id) }

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


  private
  def process_bill
    self.date ||= Time.now
    self.date_bs ||= ad_to_bs(self.date)
  end

end
