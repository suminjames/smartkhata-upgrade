class Bill < ActiveRecord::Base
  has_many :share_transactions, -> { where deleted_at: nil} #return all that are not cancelled (and therefore not have a deleted_at record)
  belongs_to :client_account
  has_many :isin_infos , through: :share_transactions

  has_and_belongs_to_many :vouchers
  has_many :particulars, through: :voucher

	enum bill_type: [ :purchase, :sales ]

  # Bill Status
  # - Pending: No payment has been done.
  # - Partial: Some but not all payment has been done.
  # - Settled: All payment has been done.
	enum status: [:pending,:partial,:settled,:cancelled]

  scope :find_not_settled, -> { where(status: [statuses[:pending], statuses[:partial]]) }
  scope :find_by_bill_type, -> (type) { where(bill_type: bill_types[:"#{type}"]) }
  #  TODO: Implement multi-name search
  scope :find_by_client_name, -> (name) { where("client_name ILIKE ?", "%#{name}%") }
  scope :find_by_bill_number, -> (number) { where("bill_number" => "#{number}") }
  scope :find_by_date, -> (date) { where(
    :updated_at => date.beginning_of_day..date.end_of_day) }
  scope :find_by_date_range, -> (date_from, date_to) { where(
    :updated_at => date_from.beginning_of_day..date_to.end_of_day) }

  # Returns total share amount from all child share_transactions
  def get_net_share_amount
			return self.share_transactions.sum(:share_amount);
  end

  # Returns total sebo commission from all child share_transactions
  def get_net_sebo_commission
			return self.share_transactions.sum(:sebo);
  end

  # Returns total net commission from all child share_transactions
  def get_net_commission
			return self.share_transactions.sum(:commission_amount);
  end

  # TODO: Implement the method.
  def get_name_transfer_amount
			return 'N/A'
  end

  # Returns total net dp fee
  def get_net_dp_fee
			return self.share_transactions.sum(:dp_fee);
  end

  # Returns total net cgt
  def get_net_cgt
			return self.share_transactions.sum(:cgt);
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

end
