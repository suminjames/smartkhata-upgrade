class ShareTransaction < ActiveRecord::Base
	belongs_to :bill
	belongs_to :isin_info
	enum trans_types: [ "buy", "sell" ]
end
