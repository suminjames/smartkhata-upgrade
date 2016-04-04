class ClientAccount < ActiveRecord::Base
	belongs_to :user
	has_one :ledger
	has_many :bills do
    def requiring_processing
      where(status: ["pending","partial"])
    end

		def requiring_receive
			where(status: [Bill.statuses[:pending],Bill.statuses[:partial]], bill_type: Bill.bill_types[:purchase])
		end

		def requiring_payment
			where(status: [Bill.statuses[:pending],Bill.statuses[:partial]], bill_type: Bill.bill_types[:sales])
		end
  end

	scope :find_by_client_name, -> (name) { where("name ILIKE ?", "%#{name}%") }
  scope :find_by_boid, -> (boid) { where("boid" => "#{boid}") }

	enum client_type: [:individual, :corporate ]
end
