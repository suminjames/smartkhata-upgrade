class Bill < ActiveRecord::Base
  has_many :share_transactions
  belongs_to :client_account
	enum bill_type: [ :receive, :pay ]
	enum status: [:raw,:pending,:partial,:settled]

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

  # TODO: Implement this
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


end
