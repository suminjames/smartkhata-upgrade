class Bill < ActiveRecord::Base
	has_many :share_transactions
	enum types: [ "receive", "pay" ]
	enum status: ["pending","partial","settled"]
end
