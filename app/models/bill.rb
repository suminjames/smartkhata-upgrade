class Bill < ActiveRecord::Base
	has_many :share_transactions
	belongs_to :client_account
	enum types: [ "receive", "pay" ]
	enum status: ["pending","partial","settled"]
end
