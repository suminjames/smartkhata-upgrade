class ClientAccount < ActiveRecord::Base
	has_many :employee_client_associations
	has_many :employee_accounts, through: :employee_client_associations
	belongs_to :user
	has_one :ledger
  has_many :share_inventories
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

  def get_current_valuation
    self.share_inventories.includes(:isin_info).sum('floorsheet_blnc * isin_infos.last_price')
  end
end
