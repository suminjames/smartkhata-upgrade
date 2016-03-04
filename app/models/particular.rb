class Particular < ActiveRecord::Base
	belongs_to :ledger
	belongs_to :voucher
	validates_presence_of :ledger_id
	enum transaction_type: [ :dr, :cr ]
end
