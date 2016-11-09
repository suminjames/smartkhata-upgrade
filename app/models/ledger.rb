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
  # include ::Models::UpdaterWithFyCode
  attr_accessor :opening_balance_type, :opening_balance_trial, :closing_balance_trial, :dr_amount_trial, :cr_amount_trial
  attr_reader :closing_balance


  INTERNALLEDGERS = ["Purchase Commission",
                     "Sales Commission",
                     "DP Fee/ Transfer",
                     "Nepse Purchase",
                     "Nepse Sales",
                     "Clearing Account",
                     "TDS",
                     "Cash",
                     "Close Out"].freeze



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

  #TODO(subas) remove updation of closing balance
  validates_presence_of :name
  # TODO(subas/saroj) look for uncommenting this.
  # validates_presence_of :group_id
  validate :positive_amount, on: :create
  before_create :update_closing_blnc
  validate :name_from_reserved?, :on => :create

  accepts_nested_attributes_for :ledger_balances

  scope :find_all_internal_ledgers, -> { where(client_account_id: nil) }
  scope :find_all_client_ledgers, -> { where.not(client_account_id: nil) }
  scope :find_by_ledger_name, -> (ledger_name) { where("name ILIKE ?", "%#{ledger_name}%") }
  scope :find_by_ledger_id, -> (ledger_id) { where(id: ledger_id) }
  scope :non_bank_ledgers, -> { where(bank_account_id: nil) }

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

  # class methods for filterrific
  def self.options_for_ledger_type
    ['client', 'internal']
  end

  def self.options_for_ledger_select(filterrific_params)
    ledger_id = filterrific_params.try(:dig, 'by_ledger_id') and where(id: ledger_id) or []
  end

  #
  # check if the ledger name clashes with system reserved ledger name
  #
  def name_from_reserved?
    if name.present? && INTERNALLEDGERS.any?{ |s| s.casecmp(name)==0 }
      errors.add :name, "The name is reserved by system" if Ledger.find_by_name("Close Out").present?
    end
  end

  def update_closing_blnc
    unless self.opening_blnc.blank?
      self.opening_blnc = self.opening_blnc * -1 if self.opening_balance_type.to_i == Particular.transaction_types['cr']
      self.closing_blnc = self.opening_blnc
    else
      self.opening_blnc = 0
    end
  end

  # def update_custom(params)
  #   valid = false
  #   self.name = params[:name]
  #   self.group_id = params[:group_id]
  #   self.vendor_account_id= params[:vendor_account_id]
  #
  #   if params[:ledger_balances_attributes]
  #     ledger_balances = []
  #     branch_ids = []
  #     total_balance = 0.0
  #
  #     params[:ledger_balances_attributes].values.each do |balance|
  #       ledger_balance = LedgerBalance.new(branch_id: balance[:branch_id],opening_balance_type: balance[:opening_balance_type], opening_balance: balance[:opening_balance])
  #       self.association(:ledger_balances).add_to_target(ledger_balance)
  #     end
  #
  #     self.ledger_balances.each do |balance|
  #       if balance.opening_balance >=0
  #         if branch_ids.include?(balance.branch_id)
  #           balance.errors.add(:branch_id, "cant have multiple entry")
  #           valid = false
  #           break
  #         end
  #         valid = true
  #         branch_ids << balance.branch_id
  #         total_balance += balance.opening_balance_type == "0" ? balance.opening_balance : ( balance.opening_balance * -1 )
  #         next
  #       end
  #       valid = false
  #       balance.errors.add(:opening_balance, "cant be a negative amount")
  #       break
  #     end
  #
  #     if valid
  #       self.association(:ledger_balances).add_to_target(LedgerBalance.new(branch_id: nil, opening_balance: total_balance))
  #       self.save
  #     else
  #       false
  #     end
  #   end
  # end

  def update_custom(params)
    valid = true
    self.name = params[:name]
    self.group_id = params[:group_id]
    self.vendor_account_id= params[:vendor_account_id]

    # TODO(sarojk): Remove this hack.
    # The following validations should have been trigerred while performing self.save. However, to avoid breaking of things at the moment, validations are done here.

    if self.group_id.blank?
      self.errors.add(:group_id, "can't be blank")
      valid = false
    end

    if self.name.blank?
      self.errors.add(:name, "can't be blank")
      valid = false
    end

    if params[:ledger_balances_attributes]
      branch_ids = []
      total_balance = 0.0

      # Associate passed in ledger_balances to this ledger object, but do not commit to db, yet!
      # 'add_to_target' ensures its not committed to db.
      params[:ledger_balances_attributes].values.each do |balance|
        # For some reasons, empty hashes of ledger balances is being sent from dom even when ledger balances are removed using the remove button. Check for their presence.
        if balance.present?
          ledger_balance = LedgerBalance.new(branch_id: balance[:branch_id],opening_balance_type: balance[:opening_balance_type], opening_balance: balance[:opening_balance])
          self.association(:ledger_balances).add_to_target(ledger_balance)
        end
      end

      self.ledger_balances.each do |balance|
        if balance.opening_balance >= 0
          # Multiple balances entries for same branch is invalid.
          if branch_ids.include?(balance.branch_id)
            balance.errors.add(:branch_id, "can't have multiple entries for same branch")
            valid = false
            break
          end
          branch_ids << balance.branch_id
          total_balance += balance.opening_balance_type == "0" ? balance.opening_balance : ( balance.opening_balance * -1 )
          next
        else
          valid = false
          balance.errors.add(:opening_balance, "can't be a negative amount")
          break
        end
      end

      if valid
        self.association(:ledger_balances).add_to_target(LedgerBalance.new(branch_id: nil, opening_balance: total_balance))
        self.save
      end
    else # in the case when there is no ledger_balances passed in.
      if valid
        self.save
      else
        false
      end
    end
  end

  # get the particulars with running balance
  def particulars_with_running_balance
    Particular.with_running_total(self.particulars)
  end

  def positive_amount
    if self.opening_blnc.to_f < 0
      errors.add(:opening_blnc, "can't be negative or blank")
    end
  end


  def closing_balance
    if self.ledger_balances.by_branch_fy_code.first.present?
      self.ledger_balances.by_branch_fy_code.first.closing_balance
    else
      # new_balance = self.ledger_balances.create!
      # new_balance.closing_balance
      0.0
    end
  end

  def opening_balance
    if self.ledger_balances.by_branch_fy_code.first.present?
      self.ledger_balances.by_branch_fy_code.first.opening_balance
    else
      0.0
    end
  end

  def dr_amount
    if self.ledger_balances.by_branch_fy_code.first.present?
      self.ledger_balances.by_branch_fy_code.first.dr_amount
    else
      0.0
    end
  end

  def cr_amount
    if self.ledger_balances.by_branch_fy_code.first.present?
      self.ledger_balances.by_branch_fy_code.first.cr_amount
    else
      0.0
    end
  end



  def self.get_ledger_by_ids(attrs = {})
    fy_code = attrs[:fy_code]
    ledger_ids = attrs[:ledger_ids] || []
    self.by_fy_code(fy_code).where(id: ledger_ids)
  end

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
  def self.find_similar_to_term(search_term)
    search_term = search_term.present? ? search_term.to_s : ''
    ledgers = Ledger.where("name ILIKE :search OR client_code ILIKE :search", search: "%#{search_term}%").order(:name).pluck_to_hash(:id, :name, :client_code, :client_account_id, :bank_account_id, :employee_account_id, :vendor_account_id)
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

end
