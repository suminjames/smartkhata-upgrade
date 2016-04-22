class Particular < ActiveRecord::Base
	include CustomDateModule
	include ::Models::UpdaterWithBranchFycode

	belongs_to :ledger
	belongs_to :voucher
	delegate :bills, :to => :voucher, :allow_nil => true

  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

	# belongs_to :receipt
	has_many :cheque_entries
	validates_presence_of :ledger_id
	enum transaction_type: [ :dr, :cr ]
	enum particular_status: [:pending, :complete]
	enum ledger_type: [:general, :has_bank]

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
		self.transaction_date ||= Time.now
		self.date_bs ||= ad_to_bs(self.transaction_date)
	end

end
