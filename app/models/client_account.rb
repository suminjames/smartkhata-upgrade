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
  belongs_to :creator, class_name: 'User'
  belongs_to :updater, class_name: 'User'

  belongs_to :group_leader, class_name: 'ClientAccount'
  has_many :group_members, :class_name => 'ClientAccount', :foreign_key => 'group_leader_id'

  belongs_to :user

  has_one :ledger
  has_many :share_inventories
  has_many :bills

  # TODO(Subas) It might not be a better idea for a client to belong to a branch but good for now
  belongs_to :branch

  scope :find_by_client_name, -> (name) { where("name ILIKE ?", "%#{name}%") }
  scope :find_by_client_id, -> (id) { where(id: id) }
  scope :find_by_boid, -> (boid) { where("boid" => "#{boid}") }
  scope :get_existing_referrers_names, -> { where.not(referrer_name: '').select(:referrer_name).distinct }
  # for future reference only .. delete if you feel you know things well enough
  # scope :having_group_members, includes(:group_members).where.not(group_members_client_accounts: {id: nil})
  scope :having_group_members, -> { joins(:group_members).uniq }
  enum client_type: [:individual, :corporate]

  validate :bank_details_present?

  def bank_details_present?
    if bank_account.present? && (bank_name.blank? || bank_address.blank?)
      errors.add :bank_account, "Please fill the required bank details"
    end
  end

  # create client ledger
  def create_ledger
    if self.nepse_code.present?
      client_ledger = Ledger.find_or_create_by!(client_code: self.nepse_code) do |ledger|
        ledger.name = self.name
        ledger.client_account_id = self.id
      end
    end
  end

  # assign the client ledger to 'Clients' group
  def assign_group
    client_group = Group.find_or_create_by!(name: "Clients")
    # append(<<) apparently doesn't append duplicate by taking care of de-duplication automatically for has_many relationships. see http://stackoverflow.com/questions/1315109/rails-idiom-to-avoid-duplicates-in-has-many-through
    client_ledger = Ledger.find(client_account_id: self.id)
    client_group.ledgers << client_ledger
  end

  def get_current_valuation
    self.share_inventories.includes(:isin_info).sum('floorsheet_blnc * isin_infos.last_price')
  end

  # get the bills of client as well as all the other bills of clients who have the client as group leader
  def get_all_related_bills
    client_account_ids = []
    client_account_ids << self.id
    client_account_ids |= self.group_members.pluck(:id)
    Bill.find_not_settled_by_client_account_ids(client_account_ids)
  end

  # get the bill ids of client as well as all the other bills of clients who have the client as group leader
  def get_all_related_bill_ids
    bill_ids = []
    client_account_ids = []
    client_account_ids << self.id
    client_account_ids |= self.group_members.pluck(:id)
    Bill.find_not_settled_by_client_account_ids(client_account_ids).pluck(:id)
  end

  def get_group_members_ledgers
    ids = self.group_members.pluck(:id)
    Ledger.where(client_account_id: ids)
  end

  def get_group_members_ledgers_with_balance
    ids = self.group_members.pluck(:id)
    Ledger.where(client_account_id: ids).where('(closing_blnc - 0.01) > ?', '0')
  end

  def get_group_members_ledger_ids
    ids = self.group_members.pluck(:id)
    Ledger.where(client_account_id: ids).pluck(:id)
  end

  # In case both numbers are messageable, 'phone' has higher priority over 'phone_perm'
  # Returns nil if neither is messageable
  def messageable_phone_number
    messageable_phone_number = nil
    if SmsMessage.messageable_phone_number?(self.phone)
      messageable_phone_number = self.phone
    elsif SmsMessage.messageable_phone_number?(self.phone_perm)
      messageable_phone_number = self.phone_perm
    end
    messageable_phone_number
  end
end
