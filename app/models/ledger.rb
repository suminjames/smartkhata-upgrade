class Ledger < ActiveRecord::Base
	has_many :particulars
	has_many :vouchers, :through => :particulars
	belongs_to :group
end
