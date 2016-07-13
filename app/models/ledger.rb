# == Schema Information
#
# Table name: ledgers
#
#  id                  :integer          not null, primary key
#  name                :string
#  client_code         :string
#  opening_blnc        :decimal(15, 4)   default("0.0")
#  closing_blnc        :decimal(15, 4)   default("0.0")
#  creator_id          :integer
#  updater_id          :integer
#  fy_code             :integer
#  branch_id           :integer
#  dr_amount           :decimal(15, 4)   default("0.0"), not null
#  cr_amount           :decimal(15, 4)   default("0.0"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  group_id            :integer
#  bank_account_id     :integer
#  client_account_id   :integer
#  employee_account_id :integer
#  vendor_account_id   :integer
#  opening_balance_org :decimal(15, 4)   default("0")
#  closing_balance_org :decimal(15, 4)   default("0")
#

class Ledger < ActiveRecord::Base
  include ::Models::UpdaterWithFyCode
  attr_accessor :opening_balance_type, :opening_balance_trial, :closing_balance_trial


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
  scope :cash_ledger, -> {where(name: 'Cash')}
  scope :bank_account_ledgers, lambda {
    ledger_ids = []
    BankAccount.all.each do |bank_account|
      ledger_ids << bank_account.ledger.id
    end
    where(id: ledger_ids)
  }

  scope :cashbook_ledgers, lambda {
    ledger_ids = []
    cash_ledger = Ledger.find_by_name('Cash')
    ledger_ids << cash_ledger.id
    BankAccount.all.each do |bank_account|
      ledger_ids << bank_account.ledger.id
    end
    where(id: ledger_ids)
  }

  #   TODO: Wipe filterrific remnants if not implemented (in the future)
  scope :cashbook_ledgers_particulars, lambda {
  }

  filterrific(
      default_filter_params: { sorted_by: 'cashbook_ledgers_desc' },
      available_filters: [
          :sorted_by,
          :by_date,
          :by_date_from,
          :by_date_to,
          :by_client_id,
          :by_cashbook_ledger_id,
      ]
  )

  scope :by_date, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where(:updated_at => date_ad.beginning_of_day..date_ad.end_of_day).order(id: :desc)
  }

  scope :by_cashbook_ledger_id, -> (id) { where(id: id).order(id: :desc) }

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^cashbook_ledgers/
        cashbook_ledgers.order(:id)
      when /^id/
        order("ledgers.id #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
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
    if self.ledger_balances.by_branch_fy_code_default.first.present?
      self.ledger_balances.by_branch_fy_code_default.first.closing_balance
    else
      new_balance = self.ledger_balances.by_branch_fy_code_default.create!
      new_balance.closing_balance
    end
  end

  def opening_balance
    if self.ledger_balances.by_branch_fy_code_default.first.present?
      self.ledger_balances.by_branch_fy_code_default.first.opening_balance
    else
      new_balance = self.ledger_balances.by_branch_fy_code_default.create!
      new_balance.opening_balance
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

 def self.options_for_cashbook_ledger_select
   Ledger.cashbook_ledgers
 end
end
