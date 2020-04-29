# == Schema Information
#
# Table name: settlements
#
#  id                        :integer          not null, primary key
#  name                      :string
#  amount                    :decimal(, )
#  date_bs                   :string
#  description               :string
#  settlement_type           :integer
#  fy_code                   :integer
#  settlement_number         :integer
#  client_account_id         :integer
#  vendor_account_id         :integer
#  creator_id                :integer
#  updater_id                :integer
#  receiver_name             :string
#  voucher_id                :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  branch_id                 :integer
#  settlement_by_cheque_type :integer          default(0)
#  date                      :date
#  belongs_to_batch_payment  :boolean
#  cash_amount               :decimal(15, 2)
#

class Settlement < ApplicationRecord
########################################
# Constants

########################################
# Includes

  class << self
    include CustomDateModule
  end
  include Auditable
  include ::Models::Updater
  include ::Models::SearchableByBranchFycode

########################################
# Relationships

  belongs_to :client_account, optional: true
  belongs_to :vendor_account, optional: true

  has_many :for_dr, -> { dr }, class_name: "ParticularSettlementAssociation"
  has_many :for_cr, -> { cr }, class_name: "ParticularSettlementAssociation"
  has_many :particular_settlement_associations
  has_many :particulars, through: :particular_settlement_associations

  has_many :debited_particulars, through: :for_dr, source: :particular
  has_many :credited_particulars, through: :for_cr, source: :particular

  belongs_to :voucher, optional: true

  # # Father of all hacks :)
  # # careful with the mapping between the type i.e settlement and cr dr of association
  # has_many :for_cheque, -> { settlement_type == "receipt" ? cr : dr }, class_name: "ParticularSettlementAssociation"
  # has_many :cheque_particulars, through: :debited_particulars, source: :particular
  has_many :cheque_entries, through: :debited_particulars

########################################
# Callbacks

  before_create :assign_settlement_number
  before_validation :add_date_from_date_bs

########################################
# Validations

  validates_presence_of :date_bs
  validates_presence_of :branch_id , :fy_code

########################################
# Enums

  enum settlement_type: [:receipt, :payment]
  enum settlement_by_cheque_type: [:not_implemented, :has_single_cheque, :has_multiple_cheques]

########################################
# Scopes

  # default_scope {where(fy_code: UserSession.selected_fy_code)}

  # scope based on the branch and fycode selection
  # default_scope do
  #   if UserSession.selected_branch_id == 0
  #     where(fy_code: UserSession.selected_fy_code)
  #   else
  #     where(branch_id: UserSession.selected_branch_id, fy_code: UserSession.selected_fy_code)
  #   end
  # end

  scope :by_settlement_type, -> (type) { where(:settlement_type => Settlement.settlement_types[type]) }

  scope :by_date, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where(:date => date_ad.beginning_of_day..date_ad.end_of_day)
  }
  scope :by_date_from, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('settlements.date >= ?', date_ad.beginning_of_day)
  }
  scope :by_date_to, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('settlements.date <= ?', date_ad.end_of_day)
  }

  scope :by_client_id, -> (id) { where(client_account_id: id) }

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^id/
       order("settlements.id #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  # might not work always with only the scope,
  # hack to make it work with the controller
  scope :with_bank_account_id, ->(bank_account_id){ where(cheque_entries: {:bank_account_id => bank_account_id}) }

  # Old implementation! Delete when successful migration to new implementation.
# scope :not_rejected, -> { joins(:voucher).where.not(vouchers: {voucher_status: Voucher.voucher_statuses[:rejected]}) }

  scope :not_rejected, -> { joins( :particulars => [:voucher]).where(vouchers: {voucher_status: Voucher.voucher_statuses[:complete]}) }

########################################
# Attributes

########################################
# Delegations

########################################
# Methods

  filterrific(
      default_filter_params: {sorted_by: 'id'},
      available_filters: [
          :sorted_by,
          :by_settlement_type,
          :by_date,
          :by_date_from,
          :by_date_to,
          :by_client_id,
          :with_bank_account_id
      ]
  )

  # TODO(sarojk): IMPORTANT! Older model implementation. Delete after migration and no hiccups.
  # def associated_cheque_entries
  #   cheque_entries_arr = Set.new
  #   associated_particulars = self.payment? ? self.debited_particulars : self.credited_particulars
  #   associated_particulars.each do |particular|
  #     particular.cheque_entries.each do |cheque_entry|
  #       cheque_entries_arr.add(cheque_entry)
  #     end
  #   end
  #   cheque_entries_arr
  # end

  # TODO(sarojk): IMPORTANT! Older model implementation. Delete after migration and no hiccups.
  # def cheque_entries
  #   cheque_entries = []
  #   cheque_numbers = Set.new
  #   # The following (nested) if logic has been borrowed from Subas's code in settlements#show view.
  #   if self.voucher.cheque_entries.present?
  #     self.voucher.cheque_entries.uniq.each do |cheque|
  #       if self.has_single_cheque? && cheque.client_account_id == self.client_account_id || !self.has_single_cheque?
  #         # in some rare cases when same account is receiving and paying
  #         # duplicate records are being seen
  #
  #         cheque_entries << cheque unless cheque_numbers.include? cheque.cheque_number
  #         cheque_numbers.add cheque.cheque_number
  #       end
  #     end
  #   end
  #   cheque_entries
  # end

  def add_date_from_date_bs
    self.date ||= self.class.bs_to_ad(self.date_bs)
    self.date_bs ||= self.class.ad_to_bs_string_public(self.date) if self.date.present?
  end

  def self.options_for_settlement_type_select
    [["Receipt", "receipt"], ["Payment", "payment"]]
  end

  #
  # get new settlement number
  #
  def self.new_settlement_number(fy_code, branch_id, settlement_type)
    settlement_type = self.settlement_types[settlement_type]
    settlement = Settlement.where(fy_code: fy_code, branch_id: branch_id, settlement_type: settlement_type).order(:settlement_number).last
    if settlement.nil?
      1
    else
      # increment the bill number
      settlement.settlement_number + 1
    end
  end

  def assign_settlement_number
    fy_code = self.fy_code
    branch_id = self.branch_id
    settlement_type = self.settlement_type
    self.settlement_number = Settlement.new_settlement_number(fy_code, branch_id, settlement_type)
    # for new creations
    # for legacy settlements cash amount is nil
    self.cash_amount ||= 0.0
  end

  # generally it is assumed that a payment is done by a single voucher
  # incase of the sales payment however one voucher makes multiple payment
  # which causes issue with the settlement show
  def belongs_to_batch_payment?
    self.belongs_to_batch_payment
  end
end
