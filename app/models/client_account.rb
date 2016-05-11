class ClientAccount < ActiveRecord::Base
	include ::Models::UpdaterWithBranch
	has_many :employee_client_associations
	# to keep track of the user who created and last updated the ledger
	belongs_to :creator,  class_name: 'User'
	belongs_to :updater,  class_name: 'User'
	# TODO: See the following associations efficient implementation
	has_many :employee_accounts, through: :employee_client_associations
	belongs_to :user
	has_one :ledger
  has_many :share_inventories
	has_many :bills

	scope :find_by_client_name, -> (name) { where("name ILIKE ?", "%#{name}%") }
  scope :find_by_boid, -> (boid) { where("boid" => "#{boid}") }

	enum client_type: [:individual, :corporate ]

  def get_current_valuation
    self.share_inventories.includes(:isin_info).sum('floorsheet_blnc * isin_infos.last_price')
  end
end
