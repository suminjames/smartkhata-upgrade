class Particular < ActiveRecord::Base
	include CustomDateModule

	belongs_to :ledger
	belongs_to :voucher
	delegate :bills, :to => :voucher, :allow_nil => true
	# belongs_to :receipt
	has_many :cheque_entries
	validates_presence_of :ledger_id
	enum transaction_type: [ :dr, :cr ]
	enum particular_status: [:pending, :complete]

	before_save :process_particular


	def get_description
		if self.description.present?
			self.description
		elsif self.name.present?
			self.name
		else
			"as per details"
		end
	end

	private
	def process_particular
		self.date_bs ||= ad_to_bs(Time.now)
	end
end
