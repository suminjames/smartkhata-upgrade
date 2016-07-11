# == Schema Information
#
# Table name: cheque_entries
#
#  id                 :integer          not null, primary key
#  beneficiary_name   :string
#  cheque_number      :integer
#  additional_bank_id :integer
#  status             :integer          default("0")
#  print_status       :integer          default("0")
#  cheque_issued_type :integer          default("0")
#  cheque_date        :date
#  amount             :decimal(15, 4)   default("0.0")
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


class ChequeEntry < ActiveRecord::Base
  extend CustomDateModule
  include ::Models::UpdaterWithBranchFycode

  belongs_to :client_account
  belongs_to :vendor_account
  belongs_to :bank_account
  belongs_to :additional_bank, class_name: "Bank"
  # belongs_to :particular

  # for many to many relation between cheque and the particulars.
  # a cheque can pay/recieve for multiple particulars.
  has_many :payments, -> { payment }, class_name: "ChequeEntryParticularAssociation"
  has_many :receipts, -> { receipt }, class_name: "ChequeEntryParticularAssociation"
  has_many :cheque_entry_particular_associations

  has_many :particulars_on_payment, through: :payments, source: :particular
  has_many :particulars_on_receipt, through: :receipts, source: :particular
  has_many :particulars, through: :cheque_entry_particular_associations


  has_many :vouchers, through: :particulars

  # validate foreign key: ensures that the bank account exists
  validates :bank_account, presence: true
  validates :cheque_number, presence: true, uniqueness: {scope: [:additional_bank_id, :bank_account_id], message: "should be unique"},
            numericality: {only_integer: true, greater_than: 0}

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
          :by_cheque_issued_type
      ]
  )

  scope :by_date, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where(:created_at => date_ad.beginning_of_day..date_ad.end_of_day)
  }
  scope :by_date_from, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('created_at>= ?', date_ad.beginning_of_day).order(id: :asc)
  }
  scope :by_date_to, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('created_at<= ?', date_ad.end_of_day).order(id: :asc)
  }

  scope :by_client_id, -> (id) { where(client_account_id: id).order(id: :asc) }
  scope :by_bank_account_id, -> (id) { where(bank_account_id: id).order(id: :asc) }
  scope :by_cheque_entry_status, lambda {|status|
    if status == 'assigned'
      where.not(:status => ChequeEntry.statuses['unassigned']).order(id: :asc)
    else
      where(:status => ChequeEntry.statuses[status]).order(id: :asc)
    end
  }
  scope :by_cheque_issued_type, -> (type) { where(:cheque_issued_type => ChequeEntry.cheque_issued_types[type]).order(id: :asc) }

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^id/
        order("cheque_entries.id #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }


  # TODO (subas) make sure to do the necessary settings
  enum status: [:unassigned, :pending_approval, :pending_clearance, :void, :approved, :bounced, :represented]
  enum print_status: [:to_be_printed, :printed]
  enum cheque_issued_type: [:payment, :receipt]

  def self.options_for_client_select
    ClientAccount.all.order(:name)
  end

  def self.options_for_bank_account_select
    BankAccount.all.order(:bank_name)
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

  def can_print?
    return true if self.payment? && !self.unassigned?
    return false
  end

end
