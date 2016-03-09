class Ledger < ActiveRecord::Base
	has_many :particulars
	has_many :vouchers, :through => :particulars
	belongs_to :group
	belongs_to :bank_account
	attr_accessor :opening_blnc_type
	validates_presence_of :name
	validate :positive_amount, on: :create

	before_create :update_closing_balance


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
