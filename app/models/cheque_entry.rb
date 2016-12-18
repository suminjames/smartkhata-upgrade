 # == Schema Information

 #
# Table name: cheque_entries
#
#  id                 :integer          not null, primary key
#  beneficiary_name   :string
#  cheque_number      :integer
#  additional_bank_id :integer
#  status             :integer          default(0)
#  print_status       :integer          default(0)
#  cheque_issued_type :integer          default(0)
#  cheque_date        :date
#  amount             :decimal(15, 4)   default(0.0)
#  bank_account_id    :integer
#  client_account_id  :integer
#  vendor_account_id  :integer
#  settlement_id      :integer
#  voucher_id         :integer
#  creator_id         :integer
#  updater_id         :integer
#  branch_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  fy_code            :integer
#


class ChequeEntry < ActiveRecord::Base
  include Auditable

  extend CustomDateModule
  include CustomDateModule
  include ::Models::UpdaterWithBranch

  attr_accessor :skip_cheque_number_validation

  belongs_to :client_account
  belongs_to :vendor_account
  belongs_to :bank_account
  belongs_to :additional_bank, class_name: "Bank"
  has_one :bank, through: :bank_account

  # belongs_to :particular

  # for many to many relation between cheque and the particulars.
  # a cheque can pay/recieve for multiple particulars.
  has_many :payments, -> { payment }, class_name: "ChequeEntryParticularAssociation"
  has_many :receipts, -> { receipt }, class_name: "ChequeEntryParticularAssociation"
  has_many :cheque_entry_particular_associations, dependent: :destroy

  has_many :particulars_on_payment, through: :payments, source: :particular
  has_many :particulars_on_receipt, through: :receipts, source: :particular
  has_many :particulars, through: :cheque_entry_particular_associations

  has_many :settlements, through: :particulars
  has_many :dr_settlements, through: :particulars_on_payment, source: :debit_settlements
  has_many :cr_settlements, through: :particulars_on_receipt, source: :credit_settlements


  has_many :vouchers, through: :particulars

  # validate foreign key: ensures that the bank account exists
  validates :bank_account, presence: true , :unless => :additional_bank_id?
  validates :cheque_number, presence: true, uniqueness: {scope: [:additional_bank_id, :bank_account_id,:cheque_issued_type], message: "should be unique"}
  validates :cheque_number, numericality: {only_integer: true, greater_than: 0} , unless: :skip_cheque_number_validation

  # TODO (subas) make sure to do the necessary settings
  #
  #  pending_approval for payment
  #  pending_clearance for receipt
  #
  enum status: [:unassigned, :pending_approval, :pending_clearance, :void, :approved, :bounced, :represented]
  enum print_status: [:to_be_printed, :printed]
  enum cheque_issued_type: [:payment, :receipt]

  # scope based on the branch
  default_scope do
    if UserSession.selected_branch_id != 0
      where(branch_id: UserSession.selected_branch_id)
    end
  end

  filterrific(
      default_filter_params: { sorted_by: 'id_asc' },
      available_filters: [
          :sorted_by,
          :by_date,
          :by_date_from,
          :by_date_to,
          :by_client_id,
          :by_bank_account_id,
          :by_cheque_entry_status,
          :by_cheque_issued_type,
          :by_cheque_number
      ]
  )

  scope :by_date, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where(:cheque_date => date_ad.beginning_of_day..date_ad.end_of_day)
  }
  scope :by_date_from, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('cheque_date >= ?', date_ad.beginning_of_day)
  }
  scope :by_date_to, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('cheque_date <= ?', date_ad.end_of_day)
  }

  # can we go with arel now?
  scope :by_client_id, -> (id) { where(client_account_id: id)
  ledger_id = Ledger.find_by(client_account_id: id)
  where([ %(
      EXISTS (
        SELECT 1
          FROM particulars p
        INNER JOIN cheque_entry_particular_associations c
          ON c.particular_id = p.id AND c.cheque_entry_id = cheque_entries.id
        WHERE p.ledger_id = ?
      )
    ),ledger_id ])
  }

  scope :by_bank_account_id, -> (id) { where(bank_account_id: id) }
  scope :by_cheque_entry_status, lambda {|status|
    if status == 'assigned'
      where.not(:status => ChequeEntry.statuses['unassigned'])
    else
      where(:status => ChequeEntry.statuses[status])
    end
  }
  scope :by_cheque_issued_type, -> (type) { where(:cheque_issued_type => ChequeEntry.cheque_issued_types[type]) }
  scope :by_cheque_number, ->(cheque_number) {where(:cheque_number => cheque_number)}


  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^id/
        order("cheque_entries.id #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }


  def self.options_for_bank_account_select
    BankAccount.by_branch_id.all.order(:bank_name)
  end

  def self.options_for_cheque_entry_status
    [
        ["Assigned" ,"assigned"],
        ["Unassigned" ,"unassigned"],
        ["Pending Approval" ,"pending_approval"],
        ["Pending Clearance" ,"pending_clearance"],
        ["Void" ,"void"],
        ["Approved" ,"approved"],
        ["Bounced" ,"bounced"],
        ["Represented" ,"represented"]
    ]
  end

  def self.options_for_cheque_issued_type
    [
        ['Payment', 'payment'],
        ['Receipt', 'receipt']
    ]
  end

  def can_print_cheque?
    if self.receipt? || self.printed? || self.unassigned?|| self.void?
      return false
    else
      return true
    end
  end

  def self.next_available_serial_cheque(bank_account_id)
    last_cheque = ChequeEntry.payment.where(bank_account_id: bank_account_id).where.not(status: "unassigned").order(:cheque_number).last
    if last_cheque.present?
      self.payment.where(bank_account_id: bank_account_id).where("cheque_number > ?", last_cheque.cheque_number).order(:cheque_number).first
    else
      self.payment.unassigned.where(bank_account_id: bank_account_id).first
    end
  end
end
