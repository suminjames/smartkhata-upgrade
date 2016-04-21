# == Schema Information
#
# Table name: particulars
#
#  id                 :integer          not null, primary key
#  opening_blnc       :decimal(15, 4)   default("0")
#  transaction_type   :integer
#  ledger_type        :integer          default("0")
#  cheque_number      :integer
#  name               :string
#  description        :string
#  amnt               :decimal(15, 4)   default("0")
#  running_blnc       :decimal(15, 4)   default("0")
#  additional_bank_id :integer
#  particular_status  :integer          default("1")
#  date_bs            :string
#  transaction_date   :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  ledger_id          :integer
#  voucher_id         :integer
#

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
