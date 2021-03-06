# == Schema Information
#
# Table name: ledger_balances
#
#  id                   :integer          not null, primary key
#  opening_balance      :decimal(15, 4)   default(0.0)
#  closing_balance      :decimal(15, 4)   default(0.0)
#  dr_amount            :decimal(15, 4)   default(0.0)
#  cr_amount            :decimal(15, 4)   default(0.0)
#  fy_code              :integer
#  branch_id            :integer
#  creator_id           :integer
#  updater_id           :integer
#  ledger_id            :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  opening_balance_type :integer
#

# Maintains the most up-to-date(rather up-to-moment) ledger attribute for the given branch_id.
#  If branch_id is nil, the organisation ledger is being referred. This organisation ledger is already up-to-moment with
#  its branches' ledger balance attributes.
class LedgerBalance < ApplicationRecord
  belongs_to :ledger
  include ::Models::UpdaterWithBranchFycodeBalance
  # attr_accessor :opening_balance_type

  # before_create :update_closing_balance

  validates :branch_id, uniqueness: { scope: %i[fy_code ledger_id] }

  validate :check_positive_amount

  before_save :update_opening_closing_balance

  enum opening_balance_type: { dr: 0, cr: 1 }
  # scope based on the branch and fycode selection

  # dont know why it was used as 0
  # perhaps the selector wont return nil
  delegate :name, to: :ledger

  # default_scope do
  #   if UserSession.selected_branch_id == 0
  #     where(fy_code: UserSession.selected_fy_code)
  #   else
  #     where(branch_id: UserSession.selected_branch_id, fy_code: UserSession.selected_fy_code)
  #   end
  # end

  def update_opening_closing_balance
    if self.opening_balance.blank?
      self.opening_balance = 0
    else
      if self.opening_balance_type == 'cr'
        self.opening_balance = self.opening_balance * -1 if self.opening_balance > 0
      end

      # when it is created make the closing balance equal to opening balance
      if self.new_record?
        self.closing_balance = self.opening_balance
      elsif self.opening_balance_changed?
        self.closing_balance = (self.opening_balance - self.opening_balance_was) + self.closing_balance
      end
    end
  end

  # # when editing the ledger balances.
  # # this considers the case when no particulars are present
  # def update_with_closing_balance(params)
  #   opening_balance = params[:opening_balance_type] == Particular.transaction_types['cr'].to_s ? params[:opening_balance].to_f * -1 :params[:opening_balance]
  #   params.merge!(closing_balance: opening_balance, opening_balance: opening_balance)
  #   self.update(params)
  # end
  #
  # def formatted_opening_balance_type
  #   @opening_balance_type || (self.opening_balance >= 0 ? :dr : :cr)
  # end

  def self.new_with_params(params)
    LedgerBalance.new(branch_id: params[:branch_id], opening_balance_type: params[:opening_balance_type], opening_balance: params[:opening_balance])
  end

  # Doubtful method because of branch id in ledgerbalance creation
  def self.update_or_create_org_balance(ledger_id, fy_code, current_user_id)
    set_current_user = lambda { |l| l.current_user_id = current_user_id }
    ledger_balance_org = LedgerBalance.unscoped.by_fy_code(fy_code).find_or_create_by!(ledger_id: ledger_id, branch_id: nil, &set_current_user)
    ledger_balance = LedgerBalance.unscoped.by_fy_code(fy_code).where(ledger_id: ledger_id).where.not(branch_id: nil).sum(:opening_balance)
    balance_type = ledger_balance >= 0 ? LedgerBalance.opening_balance_types[:dr] : LedgerBalance.opening_balance_types[:cr]
    ledger_balance_org.tap(&set_current_user)
    ledger_balance_org.update(opening_balance: ledger_balance, opening_balance_type: balance_type)
  end

  def formatted_opening_balance
    self.opening_balance.abs unless self.errors.size > 1
  end

  def check_positive_amount
    # validate if openeing balance type is sent
    # if not for leagacy support add the balance type.

    if self.opening_balance_type.present?
      errors.add(:opening_balance, "can't be negative or blank") if self.opening_balance.to_f.negative? && self.opening_balance_type != "cr"
    else
      self.opening_balance_type = 'cr' if self.opening_balance.to_f.negative?
    end
  end

  def as_json(options = {})
    ledger_name = options[:ledger_name] || name
    super.as_json(options).merge({ name: ledger_name })
  end
end
