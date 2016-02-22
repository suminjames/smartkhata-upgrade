class Bill < ActiveRecord::Base
	has_many :share_transactions
end
