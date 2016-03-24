class Voucher < ActiveRecord::Base
	include FiscalYearModule

	has_many :particulars
	has_many :ledgers, :through => :particulars
	has_and_belongs_to_many :bills
	accepts_nested_attributes_for :particulars
	has_one :settlement
	enum voucher_type: [ :journal, :purchase, :sales, :contra ]


	before_save :process_voucher

	private
	def process_voucher
		fy_code = get_fy_code
		# TODO double check the query for enum
		# rails enum and query not working properly
		last_voucher = Voucher.where(fy_code: fy_code, voucher_type: Voucher.voucher_types[self.voucher_type]).last
		self.voucher_number = last_voucher.present? ? last_voucher.voucher_number+1 : 1
		self.fy_code = fy_code
	end
end
