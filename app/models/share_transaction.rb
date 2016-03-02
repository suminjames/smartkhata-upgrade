class ShareTransaction < ActiveRecord::Base
	belongs_to :bill
	belongs_to :isin_info
	belongs_to :client_account
	enum transaction_type: [ :buy, :sell ]
end
