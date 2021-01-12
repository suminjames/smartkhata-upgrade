
# == Schema Information
#
# Table name: ledgers
#
#  id                  :integer          not null, primary key
#  name                :string
#  client_code         :string
#  opening_blnc        :decimal(15, 4)   default(0.0)
#  closing_blnc        :decimal(15, 4)   default(0.0)
#  creator_id          :integer
#  updater_id          :integer
#  fy_code             :integer
#  branch_id           :integer
#  dr_amount           :decimal(15, 4)   default(0.0), not null
#  cr_amount           :decimal(15, 4)   default(0.0), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  group_id            :integer
#  bank_account_id     :integer
#  client_account_id   :integer
#  employee_account_id :integer
#  vendor_account_id   :integer
#  opening_balance_org :decimal(15, 4)   default(0.0)
#  closing_balance_org :decimal(15, 4)   default(0.0)
#

class Ledger < ActiveRecord::Base
  # include Auditable
  extend FiscalYearModule
  include ::Models::UpdaterWithFyCode
  # remove enforce and change it to skip validation later
  attr_accessor :opening_balance_type, :opening_balance_trial, :closing_balance_trial, :dr_amount_trial, :cr_amount_trial, :enforce_validation, :changed_in_fiscal_year
  attr_reader :closing_balance

  delegate :nepse_code, to: :client_account, :allow_nil => true

  INTERNALLEDGERS = [
    "Purchase Commission",
    "Sales Commission",
    "DP Fee/ Transfer",
    "Nepse Purchase",
    "Nepse Sales",
    "Clearing Account",
    "TDS",
    "Cash",
    "Close Out",
    "Rounding Off Difference"
  ].freeze



  has_many :particulars
  has_many :vouchers, :through => :particulars
  belongs_to :group
  belongs_to :bank_account
  belongs_to :client_account
  belongs_to :vendor_account
  has_many :ledger_dailies
  has_many :ledger_balances
  has_many :employee_ledger_associations
  has_many :employee_accounts, through: :employee_ledger_associations

  validates_presence_of :name
  before_save :format_name, if: :name_changed?
  before_save :format_client_code, if: :client_code_changed?
  before_destroy :delete_associated_records
  validate :name_from_reserved?, :on => :create
  validates_presence_of :group_id, if: :enforce_validation

  # accepts_nested_attributes_for :ledger_balances, allow_destroy: true
  accepts_nested_attributes_for :ledger_balances

  scope :find_all_internal_ledgers, -> { where(client_account_id: nil) }
  scope :find_all_client_ledgers, -> { where.not(client_account_id: nil) }
  scope :find_by_ledger_name, -> (ledger_name) { where("name ILIKE ?", "%#{ledger_name}%") }
  scope :find_by_ledger_id, -> (ledger_id) { where(id: ledger_id) }
  scope :non_bank_ledgers, -> { where(bank_account_id: nil) }
  scope :restricted, -> { where(restricted: true) }
  scope :unrestricted, -> { where(restricted: false) }
  # scope :with_particulars_from_client_ledger, -> (date) { find_all_client_ledgers.joins("inner join particulars on particulars.ledger_id = ledgers.id and particulars.fy_code = #{get_fy_code(date)}")}

  scope :cashbook_ledgers, lambda {
    ledger_ids = []
    cash_ledger = Ledger.find_by_name('Cash')
    ledger_ids << cash_ledger.id
    BankAccount.all.each do |bank_account|
      ledger_ids << bank_account.ledger.id
    end
    where(id: ledger_ids)
  }

  scope :daybook_ledgers, lambda {
    self.all
  }

  filterrific(
      default_filter_params: { sorted_by: 'name_asc' },
      available_filters: [
          :sorted_by,
          :by_ledger_id,
          :by_ledger_type,
          :from_ledger_id,
          :to_ledger_id,
      ]
  )
  # scopes for filterrific
  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^name/
        order("ledgers.name #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }
  scope :by_ledger_type, -> (type) {
    if type == 'client'
      where.not(client_account_id: nil)
    else
      where(client_account_id: nil)
    end
  }
  scope :by_ledger_id, -> (id) { where(id: id) }
  scope :by_branch_id, -> (id) { where(branch_id: id) if id }

  def self.allowed show_restricted
    if(show_restricted)
      self.all
    else
      self.unrestricted
    end
  end

  def self.user_can_view_restricted?(user, path)
    user.admin? || !user.blocked_path_list.include?(path)
  end

  # class methods for filterrific
  def self.options_for_ledger_type
    ['client', 'internal']
  end

  def self.options_for_ledger_select(filterrific_params)
    ledger_id = filterrific_params.try(:dig, 'by_ledger_id') and where(id: ledger_id) or []
  end

  def format_client_code
    self.client_code = self.client_code.try(:strip).try(:upcase)
  end

  def unscoped_ledger_balances(fy_code, branch_id)
    balances = LedgerBalance.unscoped.where(ledger_id: self.id, fy_code: fy_code)
    balances = balances.where(branch_id: branch_id ) unless branch_id == 0
    balances
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

  #
  # check if the ledger name clashes with system reserved ledger name
  #
  def name_from_reserved?
    if name.present? && INTERNALLEDGERS.any?{ |s| s.casecmp(name)==0 }
      # make sure the closeout ledger is last to be added programmatically

      # errors.add :name, "The name is reserved by system" if Ledger.find_by_name("Close Out").present?

      errors.add :name, "The name is reserved by system" if Ledger.where("name ilike ?", name).count > 0
    end
  end

  def has_editable_balance?
    # not sure if this is required
    # (self.particulars.size <= 0) && (self.opening_balance == 0.0)
    # (self.particulars.size <= 0)
    true
  end

  def update_custom(params, fy_code, branch_id)
    self.save_custom(params, fy_code, branch_id)
  end

  def create_custom(fy_code, branch_id)
    self.save_custom(nil, fy_code, branch_id)
  end

  def save_custom(params = nil, fy_code = nil, branch_id = nil)
    self.enforce_validation = true
    begin
      ActiveRecord::Base.transaction do
        if params
          self.current_user_id = current_user_id
          if self.update(params)
            LedgerBalance.update_or_create_org_balance(self.id, fy_code, current_user_id)
            return true
          end
        else
          if self.save
            LedgerBalance.update_or_create_org_balance(self.id, fy_code, current_user_id)
            return true
          end
        end
      end
    rescue ActiveRecord::RecordNotUnique => e
      self.errors.add(:base, "Please make sure one entry per branch")
    end
    return false
  end

  # get the particulars with running balance
  def particulars_with_running_balance
    Particular.with_running_total(self.particulars)
  end


  def closing_balance(fy_code, branch_id = 0)
    if self.ledger_balances.by_branch_fy_code(branch_id, fy_code).first.present?
      self.ledger_balances.by_branch_fy_code(branch_id, fy_code).first.closing_balance
    else
      # new_balance = self.ledger_balances.create!
      # new_balance.closing_balance
      0.0
    end
  end

  def opening_balance(fy_code, branch_id)
    if self.ledger_balances.by_branch_fy_code(branch_id, fy_code).first.present?
      self.ledger_balances.by_branch_fy_code(branch_id, fy_code).first.opening_balance
    else
      0.0
    end
  end

  def dr_amount(fy_code, branch_id)
    if self.ledger_balances.by_branch_fy_code(branch_id, fy_code).first.present?
      self.ledger_balances.by_branch_fy_code(branch_id, fy_code).first.dr_amount
    else
      0.0
    end
  end

  def cr_amount(fy_code, branch_id)
    if self.ledger_balances.by_branch_fy_code(branch_id, fy_code).first.present?
      self.ledger_balances.by_branch_fy_code(branch_id, fy_code).first.cr_amount
    else
      0.0
    end
  end



  # def self.get_ledger_by_ids(attrs = {})
  #   fy_code = attrs[:fy_code]
  #   ledger_ids = attrs[:ledger_ids] || []
  #   self.where(id: ledger_ids)
  # end

  def descendent_ledgers(fy_code = get_fy_code)
    subtree = self.class.tree_sql_for(self)
    Ledger.by_fy_code(fy_code).where("group_id IN (#{subtree})")
  end

  #
  # Ledger name is appended with relevant code.
  # If ledger is client_account_ledger, append nepse_code.
  # And likewise...
  #
  # A ledger
  #  belongs_to :group
  #  belongs_to :bank_account
  #  belongs_to :client_account
  #  belongs_to :vendor_account
  # TODO(sarojk): Incorporate other visual identifiers for bank, vendor, employee, group, etc.
  def name_and_code
    # "#{self.name} (#{self.client_code})"
    self.client_code.present? ? "#{self.name} (#{self.client_code})" : "#{self.name}"
    # if self.client_account.present?
    #   "#{self.name} (#{self.client_code})"
    # else
    #   "#{self.name} (**Internal**)"
    # end
  end


  #
  # Searches for ledgers that have name or client_code similar to search_term provided.
  # Returns an array of hash(not Ledger objects) containing attributes sufficient to represent ledgers in combobox.
  # Attributes include id and name(identifier)
  #
  def self.find_similar_to_term(search_term, search_type)
    search_term = search_term.present? ? search_term.to_s : ''
    search_type = search_type.present? ? search_type.to_s : ''

    if search_type == 'client_group_leader_ledger'
      # voucher#new's client group leader ledger search
      ledgers = Ledger.find_all_client_ledgers.where("name ILIKE :search OR client_code ILIKE :search", search: "%#{search_term}%").order(:name).pluck_to_hash(:id, :name, :client_code, :client_account_id, :bank_account_id, :employee_account_id, :vendor_account_id)
    else
      # generic ledger search
      ledgers = Ledger.where("name ILIKE :search OR client_code ILIKE :search", search: "%#{search_term}%").order(:name).pluck_to_hash(:id, :name, :client_code, :client_account_id, :bank_account_id, :employee_account_id, :vendor_account_id)
    end
    ledgers.collect do |ledger|
      identifier = "#{ledger['name']} "
      if ledger['client_account_id'].present?
        if ledger['client_code'].present?
          identifier += "(#{ledger['client_code']})"
        end
      elsif ledger['bank_account_id'].present?
        identifier += '(**Bank Account**)'
      elsif ledger['employee_account_id'].present?
        identifier += '(**Employee**)'
      elsif ledger['vendor_account_id'].present?
        identifier += "(**Vendor**)"
      else
        # Internal Ledger
        identifier += "(**Internal**)"
      end
      { :text=> identifier, :id => ledger['id'].to_s }
    end
  end

  # TODO(sarojk): Incorporate more types as added.
  def name_and_identifier
    identifier = ""
    if client_account_id.present?
      if client_code.present?
        identifier = "(#{client_code})"
      end
    elsif bank_account_id.present?
      identifier = '(**Bank Account**)'
    elsif employee_account_id.present?
      identifier = '(**Employee**)'
    elsif vendor_account_id.present?
      identifier = "(**Vendor**)"
    else
      # Internal Ledger
      identifier = "(**Internal**)"
    end
    "#{name} #{identifier}"
  end

  def delete_associated_records
    LedgerBalance.unscoped.where(ledger_id: self.id).delete_all
    LedgerDaily.where(ledger_id: self.id).delete_all
  end

  def effective_branch
    # todo different branch_ids for different type of accounts
    if self.client_account_id
      self.client_account.branch_id
    # elsif self.vendor_account_id
    #   self.vendor_account.branch_id

    # elsif self.employee_account_id
    #   EmployeeAccount.find(self.employee_account_id).branch_id
    end

  end
end
