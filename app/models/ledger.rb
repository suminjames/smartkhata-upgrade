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

  def update_custom(params)
    self.name = params[:name]
    self.group_id = params[:group_id]
    self.vendor_account_id= params[:vendor_account_id]
    unless params[:opening_blnc].nil?
      self.opening_blnc = params[:opening_blnc_type].to_i == Particular.transaction_types['cr'] ? params[:opening_blnc].to_f * -1 : params[:opening_blnc].to_f.abs
      self.closing_blnc = self.opening_blnc
    end
    self.save!
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
    if self.client_account.present?
      "#{self.name} (#{self.client_code})"
    else
      "#{self.name} (**Internal**)"
    end
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
        identifier += "(#{ledger['client_code']})"
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
