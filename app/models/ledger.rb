class Ledger < ActiveRecord::Base
	has_many :particulars
	has_many :vouchers, :through => :particulars
	belongs_to :group
	attr_accessor :opening_blnc_type
	validates_presence_of :name
end
