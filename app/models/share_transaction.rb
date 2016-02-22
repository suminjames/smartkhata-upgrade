class ShareTransaction < ActiveRecord::Base
	belongs_to :bill
	enum trans_types: [ "buy", "sell" ]
end
