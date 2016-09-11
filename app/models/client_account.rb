# == Schema Information
#
# Table name: client_accounts
#
#  id                        :integer          not null, primary key
#  boid                      :string
#  nepse_code                :string
#  client_type               :integer          default(0)
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
#  invited                   :boolean          default(FALSE)
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

  # 36 fields present. Validate accordingly!
  validates_presence_of :name, :citizen_passport, :dob, :father_mother, :granfather_father_inlaw, :address1_perm, :city_perm, :state_perm, :country_perm,
                        :unless => :nepse_code?
  validates_format_of :dob, with: DATE_REGEX, message: 'should be in YYYY-MM-DD format', allow_blank: true
  validates_format_of :citizen_passport_date, with: DATE_REGEX, message: 'should be in YYYY-MM-DD format', allow_blank: true
  validates_format_of :email, with: EMAIL_REGEX, allow_blank: true
  validates_numericality_of :mobile_number, only_integer: true, allow_blank: true # length?
  validates_presence_of :bank_name, :bank_address, :bank_account, :if => :any_bank_field_present?
  validates :bank_account, uniqueness: true, format: {with: ACCOUNT_NUMBER_REGEX, message: 'should be numeric or alphanumeric'}, :if => :any_bank_field_present?
  validates_uniqueness_of :nepse_code, :allow_blank => true
  # validates :name, :father_mother, :granfather_father_inlaw, format: { with: /\A[[:alpha:][:blank:]]+\Z/, message: 'only alphabets allowed' }
  # validates :address1_perm, :city_perm, :state_perm, :country_perm, format: { with: /\A[[:alpha:]\d,. ]+\Z/, message: 'special characters not allowed' }

  scope :find_by_client_name, -> (name) { where("name ILIKE ?", "%#{name}%") }
  scope :by_client_id, -> (id) { where(id: id) }
  scope :find_by_boid, -> (boid) { where("boid" => "#{boid}") }
  # for future reference only .. delete if you feel you know things well enough
  # scope :having_group_members, includes(:group_members).where.not(group_members_client_accounts: {id: nil})
  scope :having_group_members, -> { joins(:group_members).uniq }
  enum client_type: [:individual, :corporate]

  filterrific(
      default_filter_params: { sorted_by: 'name_asc' },
      available_filters: [
          :sorted_by,
          :by_client_id,
          :client_filter
      ]
  )

  scope :client_filter, lambda {|status|
    # [
    #     ["without Mobile Number", "no_mobile_number"],
    #     ["without any Phone Number", "no_any_phone_number"],
    #     ["without Email", "no_email"],
    #     ["without BOID", "no_boid"],
    #     ["without Nepse Code", "no_nepse_code"]
    # ]
    case status
      when 'no_mobile_number'
        where(:mobile_number => [nil, '']).order('name asc')
      when 'no_any_phone_number'
        where(:mobile_number => [nil, '']).where(:phone_perm => [nil, '']).where(:phone => [nil, '']).order('name asc')
      when 'no_email'
        where(:email => [nil, '']).order('name asc')
      when 'no_boid'
        where(:boid => [nil, '']).order('name asc')
      when 'no_nepse_code'
        where(:nepse_code => [nil, '']).order('name asc')
    end
  }

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^name/
        order("client_accounts.name #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  validate :bank_details_present?

  def bank_details_present?
    if bank_account.present? && (bank_name.blank? || bank_address.blank?)
      errors.add :bank_account, "Please fill the required bank details"
    end
  end

  # create client ledger
  def create_ledger
    client_group = Group.find_or_create_by!(name: "Clients")
    if self.nepse_code.present?
      client_ledger = Ledger.find_or_create_by!(client_code: self.nepse_code) do |ledger|
        ledger.name = self.name
        ledger.client_account_id = self.id
        ledger.group_id = client_group.id
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
    Ledger.where(client_account_id: ids).where('(closing_balance - 0.01) > ?', '0')
  end

  def get_group_members_ledger_ids
    ids = self.group_members.pluck(:id)
    Ledger.where(client_account_id: ids).pluck(:id)
  end

  # Priority: mobile_number > phone > phone_perm
  # Returns nil if neither is messageable
  def messageable_phone_number
    messageable_phone_number = nil
    if SmsMessage.messageable_phone_number?(self.mobile_number)
      messageable_phone_number = self.mobile_number
    elsif SmsMessage.messageable_phone_number?(self.phone)
      messageable_phone_number = self.phone
    elsif SmsMessage.messageable_phone_number?(self.phone_perm)
      messageable_phone_number = self.phone_perm
    end
    messageable_phone_number
  end

  # validation helper
  def any_bank_field_present?
    bank_name? || bank_address? || bank_account?
  end

  def name_and_nepse_code
    "#{self.name.titleize} (#{self.nepse_code})"
  end

  def commaed_contact_numbers
    str = ''
    str += self.mobile_number + ', ' if self.mobile_number.present?
    str += self.phone + ', ' if self.phone.present?
    str += self.phone_perm if self.phone_perm.present?
    # strip leading or trailing comma ','
    str[0..1]= '' if str[0..1] == ', '
    str[-2..-1]= '' if str[-2..-1] == ', '
    str
  end

  def self.existing_referrers_names
    where.not(referrer_name: '').order(:referrer_name).uniq.pluck(:referrer_name)
  end

  def self.options_for_client_select(filterrific_params)
    client_arr = []
    if filterrific_params.present? && filterrific_params[:by_client_id].present?
      client_id = filterrific_params[:by_client_id]
      client_arr = self.by_client_id(client_id)
    end
    client_arr
  end

  def self.options_for_client_filter
    [
        ["without Mobile Number", "no_mobile_number"],
        ["without any Phone Number", "no_any_phone_number"],
        ["without Email", "no_email"],
        ["without BOID", "no_boid"],
        ["without Nepse Code", "no_nepse_code"]
    ]
  end

  def self.pretty_string_of_filter_identifier(filter_identifier)
    filter_identifier ||= ''
    pretty_string = ''
    arr = [
        ["without Mobile Number", "no_mobile_number"],
        ["without any Phone Number", "no_any_phone_number"],
        ["without Email", "no_email"],
        ["without BOID", "no_boid"],
        ["without Nepse Code", "no_nepse_code"]
    ]
    arr.each do |sub_arr|
      if filter_identifier == sub_arr[1]
        pretty_string = sub_arr[0]
        return pretty_string
      end
    end
    pretty_string
  end

  #
  # Searches for client accounts that have name or client_code similar to search_term provided.
  # Returns an array of hash(not ClientAccount objects) containing attributes sufficient to represent clients in combobox.
  # Attributes include id and name(identifier)
  #
  def self.find_similar_to_term(search_term)
    search_term = search_term.present? ? search_term.to_s : ''
    client_accounts = ClientAccount.where("name ILIKE :search OR nepse_code ILIKE :search", search: "%#{search_term}%").order(:name).pluck_to_hash(:id, :name, :nepse_code)
    client_accounts.collect do |client_account|
      identifier = "#{client_account['name']} (#{client_account['nepse_code']})"
      { :text=> identifier, :id => client_account['id'].to_s }
    end
  end

  #
  # Create dummy data(client accounts and associated ledgers) to test speed improvements, while accessing combobox.
  # Never to be used in production.
  #
  def self.populate_dummy_data
    if !Rails.env.production?
      10000.times do |i|
        i = i + 10
        new_client = ClientAccount.new
        new_client.name = "Client#{i}"
        new_client.nepse_code = "NepseCode#{i}"
        new_client.citizen_passport = i
        new_client.dob = '1988-12-21'
        new_client.father_mother = 'Client Father'
        new_client.granfather_father_inlaw = 'Client Mother'
        new_client.address1_perm = 'Permanent Address 1'
        new_client.city_perm = 'Permanent City'
        new_client.state_perm = 'Permanent State'
        new_client.country_perm = 'Permanent Country'
        new_client.save!

        new_ledger = Ledger.new
        new_ledger.name = new_client.name
        new_ledger.client_account_id = new_client.id
        new_ledger.client_code = new_client.nepse_code
        new_ledger.save!
      end
    end
  end

end
