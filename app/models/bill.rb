class Bill < ActiveRecord::Base
  has_many :share_transactions
  belongs_to :client_account
	enum types: [ "receive", "pay" ]
	enum status: ["pending","partial","settled"]

  # Returns total share amount from all child share_transactions
  def get_share_amount
			return self.share_transactions.sum(:share_amount);
  end

  # Returns total sebo commision from all child share_transactions
  def get_sebo_commision
			return self.share_transactions.sum(:sebo);
  end

  # Returns net amount (either payable or recievable) from all child share_transactions.
	# A bill is either payable or recievable is determined by transaction_type
  def get_net_amount
			return self.share_transactions.sum(:sebo);
  end


end
