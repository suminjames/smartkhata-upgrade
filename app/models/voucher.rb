# == Schema Information
#
# Table name: vouchers
#
#  id              :integer          not null, primary key
#  fy_code         :integer
#  voucher_number  :integer
#  date            :date
#  date_bs         :string
#  desc            :string
#  voucher_type    :integer          default("0")
#  voucher_status  :integer          default("0")
#  is_payment_bank :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Voucher < ActiveRecord::Base
	include FiscalYearModule

	has_many :particulars
	has_many :share_transactions
	has_many :ledgers, :through => :particulars
	has_many :cheque_entries, :through => :particulars
	has_and_belongs_to_many :bills
	accepts_nested_attributes_for :particulars
	has_one :settlement

	# purchase and sales kept as per the accounting norm
  # however voucher types will be represented as payment and receive
	enum voucher_type: [ :journal, :purchase, :sales, :contra ]
	enum voucher_status: [:pending, :complete, :rejected]

	before_save :process_voucher

	def voucher_code
		case self.voucher_type
		when 'journal'
			"JVR"
		when 'purchase'
			"PMT"
		when 'sales'
			"RCV"
		when Voucher.voucher_types[:contra]
			"CVR"
		else
			"NA"
		end
	end

	private
	def process_voucher
		fy_code = get_fy_code
		# TODO double check the query for enum
		# rails enum and query not working properly
		last_voucher = Voucher.where(fy_code: fy_code, voucher_type: Voucher.voucher_types[self.voucher_type]).last
		self.voucher_number ||= last_voucher.present? ? last_voucher.voucher_number+1 : 1
		self.fy_code = fy_code
		self.date = Time.now
	end

end
