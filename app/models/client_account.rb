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
#  company_address           :string
#  company_id                :string
#  invited                   :boolean          default("false")
#  referrer_name             :string
#  group_leader_id           :integer
#  creator_id                :integer
#  updater_id                :integer
#  branch_id                 :integer
#  user_id                   :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  mobile_number             :string
#  ac_code                   :string
#




# Note: 
# - From dpa5, pretty much everything including BOID (but not Nepse-code) of a client can be fetched
# - From floorsheet, only client name and NEPSE-code of a client can be fetched.
# The current implementation doesn't have  a way to match a client's BOID with Nepse-code but from manual intervention.
class ClientAccount < ActiveRecord::Base
	include ::Models::UpdaterWithBranch

  after_create :create_ledger

  # to keep track of the user who created and last updated the ledger
	belongs_to :creator,  class_name: 'User'
	belongs_to :updater,  class_name: 'User'

  belongs_to :group_leader,  class_name: 'ClientAccount'

	belongs_to :user

	has_one :ledger
  has_many :share_inventories
	has_many :bills


	scope :find_by_client_name, -> (name) { where("name ILIKE ?", "%#{name}%") }
	scope :find_by_client_id, -> (id) { where(id: id) }
  scope :find_by_boid, -> (boid) { where("boid" => "#{boid}") }
  scope :get_existing_referrers_names, -> { where.not(referrer_name: '').select(:referrer_name).distinct}

	enum client_type: [:individual, :corporate ]

  # create client ledger
  def create_ledger
    client_ledger = Ledger.find_or_create_by!(client_code: self.nepse_code) do |ledger|
      ledger.name = self.name
      ledger.client_account_id = self.id
    end
  end

  # assign the client ledger to 'Clients' group
  def assign_group
		client_group = Group.find_or_create_by!(name: "Clients")
    # append(<<) apparently doesn't append duplicate by taking care of de-duplication automatically for has_many relationships. see http://stackoverflow.com/questions/1315109/rails-idiom-to-avoid-duplicates-in-has-many-through
    client_ledger = Ledger.find(client_account_id: self.id)
		client_group.ledgers <<  client_ledger
  end

  def get_current_valuation
    self.share_inventories.includes(:isin_info).sum('floorsheet_blnc * isin_infos.last_price')
  end
end
