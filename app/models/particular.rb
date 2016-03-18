class Particular < ActiveRecord::Base
	belongs_to :ledger
	belongs_to :voucher
	belongs_to :bill
	belongs_to :receipt

	has_many :cheque_entries
	validates_presence_of :ledger_id
	enum transaction_type: [ :dr, :cr ]
end
