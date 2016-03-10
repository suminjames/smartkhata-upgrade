class ClientAccount < ActiveRecord::Base
	belongs_to :user
	has_one :ledger
	has_many :bills do
    def requiring_processing
      where(status: ["pending","partial"])
    end

		def requiring_receive
			where(status: [Bill.statuses[:pending],Bill.statuses[:partial]], bill_type: Bill.bill_types[:pay])
		end

		def requiring_payment
			where(status: [Bill.statuses[:pending],Bill.statuses[:partial]], bill_type: Bill.bill_types[:receive])
		end
  end
end
