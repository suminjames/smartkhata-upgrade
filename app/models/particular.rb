class Particular < ActiveRecord::Base
	belongs_to :ledger
	belongs_to :voucher

	enum transaction_type: [ "dr", "cr" ]
end
