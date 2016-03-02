class Bill < ActiveRecord::Base
  has_many :share_transactions
  belongs_to :client_account
	enum bill_type: [ "receive", "pay" ]
	enum status: ["pending","partial","settled"]

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

  # TODO
  # Returns net amount (either payable or recievable) from all child share_transactions.
	# A bill is either payable or recievable is determined by transaction_type
  def get_net_bill_amount
    #return self.share_transactions.sum(:sebo);
  end


end
