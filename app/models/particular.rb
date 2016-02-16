class Particular < ActiveRecord::Base
	belongs_to :ledger
	belongs_to :voucher

	enum trans_types: [ "Dr", "Cr" ]
end
