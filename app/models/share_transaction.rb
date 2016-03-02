class ShareTransaction < ActiveRecord::Base
	belongs_to :bill
	belongs_to :isin_info
	enum transaction_type: [ "buy", "sell" ]

end
