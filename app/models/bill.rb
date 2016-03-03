class Bill < ActiveRecord::Base
  has_many :share_transactions
  belongs_to :client_account
	enum type: [ "receive", "pay" ]
	enum status: ["pending","partial","settled"]

  # Performs query on search as per 'search_by' and 'search_term'
  def self.search(search_by, search_term)
    case search_by
    when "client_name"
      where("client_name ILIKE ?", "%#{search_term}%")
    when "bill_number"
      where("bill_number" => "#{search_term}")
    when "date"
      search_term = Date.parse(search_term)
      where(
      :updated_at => search_term.beginning_of_day..search_term.end_of_day)
    when "date_range"
      # TODO Check for valid date and notify user if invalid
      date_from = Date.parse(search_term['date_from'])
      date_to   = Date.parse(search_term['date_to'])
      where(
      :updated_at => date_from.beginning_of_day..date_to.end_of_day)
    end
  end

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
