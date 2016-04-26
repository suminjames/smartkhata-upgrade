class Ledger < ActiveRecord::Base

	include ::Models::UpdaterWithBranchFycode

	has_many :particulars
	has_many :vouchers, :through => :particulars
	belongs_to :group
	belongs_to :bank_account
	belongs_to :client_account
	attr_accessor :opening_blnc_type
	has_many :ledger_dailies

  # to keep track of the user who created and last updated the ledger
	belongs_to :creator,  class_name: 'User'
	belongs_to :updater,  class_name: 'User'

	validates_presence_of :name
	# validates_presence_of :group_id
	validate :positive_amount, on: :create

	before_create :update_closing_balance

	scope :find_all_internal_ledgers, -> { where(client_account_id: nil) }
  scope :find_all_client_ledgers, -> { where.not(client_account_id: nil) }
  scope :find_by_ledger_name, -> (ledger_name) { where("name ILIKE ?", "%#{ledger_name}%") }

	def update_closing_balance
		unless self.opening_blnc.nil?
			self.opening_blnc = self.opening_blnc * -1 if self.opening_blnc_type.to_i == Particular.transaction_types['cr']
			self.closing_blnc = self.opening_blnc
		end
	end

	def positive_amount
		if self.opening_blnc < 0
      errors.add(:opening_blnc, "can't be negative")
		end
	end
end
