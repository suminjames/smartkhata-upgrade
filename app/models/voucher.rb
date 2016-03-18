class Voucher < ActiveRecord::Base
	has_many :particulars
	has_many :ledgers, :through => :particulars
	accepts_nested_attributes_for :particulars
	has_one :receipt

	enum voucher_type: [ :journal, :purchase, :sales, :contra ]
end
