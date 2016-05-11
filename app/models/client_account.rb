# == Schema Information
#
# Table name: client_accounts
#
#  id                        :integer          not null, primary key
#  boid                      :string
#  nepse_code                :string
#  client_type               :integer          default("0")
#  date                      :date
#  name                      :string
#  address1                  :string           default(" ")
#  address1_perm             :string
#  address2                  :string           default(" ")
#  address2_perm             :string
#  address3                  :string
#  address3_perm             :string
#  city                      :string           default(" ")
#  city_perm                 :string
#  state                     :string
#  state_perm                :string
#  country                   :string           default(" ")
#  country_perm              :string
#  phone                     :string
#  phone_perm                :string
#  customer_product_no       :string
#  dp_id                     :string
#  dob                       :string
#  sex                       :string
#  nationality               :string
#  stmt_cycle_code           :string
#  ac_suspension_fl          :string
#  profession_code           :string
#  income_code               :string
#  electronic_dividend       :string
#  dividend_curr             :string
#  email                     :string
#  father_mother             :string
#  citizen_passport          :string
#  granfather_father_inlaw   :string
#  purpose_code_add          :string
#  add_holder                :string
#  husband_spouse            :string
#  citizen_passport_date     :string
#  citizen_passport_district :string
#  pan_no                    :string
#  dob_ad                    :string
#  bank_name                 :string
#  bank_account              :string
#  bank_address              :string
#  company_name              :string
#  company_id                :string
#  invited                   :boolean          default("false")
#  creator_id                :integer
#  updater_id                :integer
#  branch_id                 :integer
#  user_id                   :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

# Note: 
# - From dpa5, pretty much everything including BOID (but not Nepse-code) of a client can be fetched
# - From floorsheet, only client name and NEPSE-code of a client can be fetched.
# The current implementation doesn't have  a way to match a client's BOID with Nepse-code but from manual intervention.
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
	scope :find_by_client_id, -> (id) { where(id: id) }
  scope :find_by_boid, -> (boid) { where("boid" => "#{boid}") }

	enum client_type: [:individual, :corporate ]

  def get_current_valuation
    self.share_inventories.includes(:isin_info).sum('floorsheet_blnc * isin_infos.last_price')
  end
end
