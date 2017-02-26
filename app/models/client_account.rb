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
  ########################################
  # Constants

  ########################################
  # Includes
  include Auditable
  include ::Models::UpdaterWithBranch

  ########################################
  # Relationships
  # to keep track of the user who created and last updated the ledger
  belongs_to :creator, class_name: 'User'
  belongs_to :updater, class_name: 'User'
  belongs_to :group_leader, class_name: 'ClientAccount'
  has_many :group_members, :class_name => 'ClientAccount', :foreign_key => 'group_leader_id'
  belongs_to :user
  has_one :ledger
  has_many :share_inventories
  has_many :bills
  belongs_to :branch

  ########################################
  # Callbacks

  # before_validation is heirarchically called before before_save
  before_validation :format_nepse_code, if: :nepse_code_changed?
  before_save :format_name, if: :name_changed?
  after_create :create_ledger

  ########################################
  # Validations
  # Too many fields present. Validate accordingly!
  validates_presence_of :name,
                        :unless => :nepse_code?
  validates_presence_of :branch_id, :if => lambda { Branch.has_multiple_branches? }
  validates_presence_of :citizen_passport, :dob, :father_mother, :granfather_father_inlaw, :address1_perm, :city_perm, :state_perm, :country_perm,
                        :if => lambda {|record| record.nepse_code.blank?  && record.individual? && !record.skip_validation_for_system}
  validates_presence_of :address1_perm, :city_perm, :state_perm, :country_perm,
                        :if => lambda {|record| record.nepse_code.blank?  && record.corporate? && !record.skip_validation_for_system}
  validates_format_of :dob, with: DATE_REGEX, message: 'should be in YYYY-MM-DD format', allow_blank: true, unless: :skip_validation_for_system
  validates_format_of :citizen_passport_date, with: DATE_REGEX, message: 'should be in YYYY-MM-DD format', allow_blank: true,  unless: :skip_validation_for_system
  validates_format_of :email, with: EMAIL_REGEX, allow_blank: true
  validates_numericality_of :mobile_number, only_integer: true, allow_blank: true, unless: :skip_validation_for_system # length?
  validates_presence_of :bank_name, :bank_address, :bank_account, :if => :any_bank_field_present?
  validates :bank_account, uniqueness: true, format: {with: ACCOUNT_NUMBER_REGEX, message: 'should be numeric or alphanumeric'}, :if => :any_bank_field_present?
  validates_uniqueness_of :nepse_code, :allow_blank => true
  # validates :name, :father_mother, :granfather_father_inlaw, format: { with: /\A[[:alpha:][:blank:]]+\Z/, message: 'only alphabets allowed' }
  # validates :address1_perm, :city_perm, :state_perm, :country_perm, format: { with: /\A[[:alpha:]\d,. ]+\Z/, message: 'special characters not allowed' }
  validate :bank_details_present?

  ########################################
  # Enums
  enum client_type: [:individual, :corporate]

  ########################################
  # Scopes
  scope :by_client_id, -> (id) { where(id: id) }
  scope :find_by_boid, -> (boid) { where("boid" => "#{boid}") }
  # for future reference only .. delete if you feel you know things well enough
  # scope :having_group_members, includes(:group_members).where.not(group_members_client_accounts: {id: nil})
  scope :having_group_members, -> { joins(:group_members).uniq }
  scope :by_selected_session_branch_id, lambda {|session_branch_id|
    if session_branch_id != 0
      where(branch_id: session_branch_id)
    end
  }
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
      when 'with_boid'
        where.not(:boid => [nil, '']).order('name asc')
      when 'with_nepse_code'
        where.not(:nepse_code => [nil, '']).order('name asc')
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

  ########################################
  # Attributes
  attr_accessor :skip_validation_for_system

  ########################################
  # Delegations

  ########################################
  # Methods

  filterrific(
      default_filter_params: { sorted_by: 'name_asc' },
      available_filters: [
          :sorted_by,
          :by_client_id,
          :client_filter,
          :by_selected_session_branch_id
      ]
  )


  def format_nepse_code
    self.nepse_code = self.nepse_code.try(:strip).try(:upcase)
  end

  #
  # Where applicable,
  #   - Strip name of trailing and leading white space.
  #   - Remove more than one spaces from in between name.
  #
  def format_name
    if self.name.present?
      name_is_strippable = self.name.strip != self.name
      name_has_more_than_one_space_in_between_words = (self.name.split(" ").count - 1 ) != self.name.count(" ")
      if name_is_strippable
        self.name =  self.name.strip
      end
      if name_has_more_than_one_space_in_between_words
        # http://stackoverflow.com/questions/4662015/ruby-reduce-all-whitespace-to-single-spaces
        self.name = self.name.gsub(/\s+/, ' ')
      end
    end
    self.name
  end

  def skip_or_nepse_code_present?
    nepse_code? || skip_validation_for_system
  end

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
    else
      client_ledger = Ledger.new
      client_ledger.name = self.name
      client_ledger.client_account_id = self.id
      client_ledger.group_id = client_group.id
      client_ledger.save!
    end

    client_ledger
  end

  def find_or_create_ledger
    return self.ledger if self.ledger.present?
    create_ledger
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
    Ledger.where(client_account_id: ids)
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

  def can_be_invited_by_email?
    user_id.blank? && email.present?
  end

  def can_assign_username?
    user_id.blank? && boid.present?
  end

  def has_sufficient_bank_account_info?
    bank_name.present? && bank_account.present?
  end

  # validation helper
  def any_bank_field_present?
    bank_name? || bank_address? || bank_account?
  end

  def name_and_nepse_code
    if self.nepse_code.present?
      "#{self.name.titleize} (#{self.nepse_code})"
    else
      "#{self.name.titleize}"
    end
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

  def pending_bills_path
    Rails.application.routes.url_helpers.bills_path("filterrific[by_client_id]":"#{self.id}", "filterrific[by_bill_status]":"pending")
  end

  def share_inventory_path
    Rails.application.routes.url_helpers.share_transactions_path("filterrific[by_client_id]":"#{self.id}")
  end


  def ledger_closing_balance
    self.ledger.closing_balance
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

  def self.options_for_client_select_closeouts(filterrific_params)
    client_arr = []
    if filterrific_params.present? && filterrific_params[:by_client_id_closeouts].present?
      client_id = filterrific_params[:by_client_id_closeouts]
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
        ["without Nepse Code", "no_nepse_code"],
        ["with BOID", "with_boid"]
    ]
  end

  def self.pretty_string_of_filter_identifier(filter_identifier)
    filter_identifier ||= ''
    pretty_string = ''

    arr = self.options_for_client_filter

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
  def self.find_similar_to_term(search_term, branch_id)
    search_term = search_term.present? ? search_term.to_s : ''
    client_accounts = ClientAccount.by_selected_session_branch_id(branch_id).where("name ILIKE :search OR nepse_code ILIKE :search", search: "%#{search_term}%").order(:name).pluck_to_hash(:id, :name, :nepse_code)
    client_accounts.collect do |client_account|
      if client_account['nepse_code'].present?
        identifier = "#{client_account['name']} (#{client_account['nepse_code']})"
      else
        identifier = "#{client_account['name']}"
      end
      { :text=> identifier, :id => client_account['id'].to_s }
    end
  end

  def ok_to_delete?
  # A client_account
    # belongs_to :creator, class_name: 'User'
    # belongs_to :updater, class_name: 'User'
    # belongs_to :group_leader, class_name: 'ClientAccount'
    # has_many :group_members, :class_name => 'ClientAccount', :foreign_key => 'group_leader_id'
    # belongs_to :user
    # has_one :ledger
    # has_many :share_inventories
    # has_many :bills
    # belongs_to :branch
    unless (self.group_members.empty? && self.user.nil? && self.ledger.nil? && self.bills.empty?)
      return false
    end

    #  Other attachments
    # - cheque_entry
    # - order
    # - settlement
    # - share_inventories
    # - share_transactions
    # - transaction_messages
    ['ChequeEntry', 'Order', 'Settlement', 'ShareInventory', 'ShareTransaction', 'TransactionMessage'].each do |model|
      model = model.constantize
      if model.unscoped.where(client_account_id: self.id).size != 0
        return false
      end
    end
    return true
  end
end
