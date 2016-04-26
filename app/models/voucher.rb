class Voucher < ActiveRecord::Base
	include FiscalYearModule
	include ::Models::UpdaterWithBranchFycode

	has_many :particulars
	has_many :share_transactions
	has_many :ledgers, :through => :particulars
	has_many :cheque_entries, :through => :particulars
	
	accepts_nested_attributes_for :particulars
	has_one :settlement


	has_many :on_creation, -> { on_creation }, class_name: "BillVoucherRelation"
	has_many :on_settlement, -> { on_settlement }, class_name: "BillVoucherRelation"
	has_many :bill_voucher_relations

	has_many :bills_on_creation, through: :on_creation, source: :bill
	has_many :bills_on_settlement, through: :on_settlement, source: :bill
	has_many :bills , through: :bill_voucher_relations


  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'
  belongs_to :reviewer, class_name: 'User'

	# purchase and sales kept as per the accounting norm
  # however voucher types will be represented as payment and receive
	enum voucher_type: [ :journal, :purchase, :sales, :contra ]
	enum voucher_status: [:pending, :complete, :rejected]

	before_create :add_branch_fycode
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
		# self.fy_code = fy_code
		self.date = Time.now
	end

end