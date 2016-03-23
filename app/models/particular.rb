class Particular < ActiveRecord::Base
	belongs_to :ledger
	belongs_to :voucher
	delegate :bills, :to => :voucher, :allow_nil => true
	# belongs_to :receipt
	has_many :cheque_entries
	validates_presence_of :ledger_id
	enum transaction_type: [ :dr, :cr ]
end
