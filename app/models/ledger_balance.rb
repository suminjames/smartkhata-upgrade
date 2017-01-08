# == Schema Information
#
# Table name: ledger_balances
#
#  id              :integer          not null, primary key
#  opening_balance :decimal(15, 4)   default(0.0)
#  closing_balance :decimal(15, 4)   default(0.0)
#  dr_amount       :decimal(15, 4)   default(0.0)
#  cr_amount       :decimal(15, 4)   default(0.0)
#  fy_code         :integer
#  branch_id       :integer
#  creator_id      :integer
#  updater_id      :integer
#  ledger_id       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

# Maintains the most up-to-date(rather up-to-moment) ledger attribute for the given branch_id.
#  If branch_id is nil, the organisation ledger is being referred. This organisation ledger is already up-to-moment with
#  its branches' ledger balance attributes.
class LedgerBalance < ActiveRecord::Base
  belongs_to :ledger
  include ::Models::UpdaterWithBranchFycodeBalance
  # attr_accessor :opening_balance_type
  before_create :update_closing_balance

  validates :branch_id, :uniqueness => { scope: [:fy_code, :ledger_id] }

  validate :check_positive_amount

  before_save :update_closing_balance

  enum opening_balance_type: [:dr, :cr]
  # scope based on the branch and fycode selection

  # dont know why it was used as 0
  # perhaps the selector wont return nil

  default_scope do
    if UserSession.selected_branch_id == 0
      where(fy_code: UserSession.selected_fy_code)
    else
      where(branch_id: UserSession.selected_branch_id, fy_code: UserSession.selected_fy_code)
    end
  end

  def update_closing_balance
    unless self.opening_balance.blank?
      if self.opening_balance_type == 'cr'
        if self.opening_balance > 0
          self.opening_balance = self.opening_balance * -1
        end
      end
      self.closing_balance = self.opening_balance
    else
      self.opening_balance = 0
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
    LedgerBalance.new(branch_id: params[:branch_id],opening_balance_type: params[:opening_balance_type], opening_balance: params[:opening_balance])
  end

  def formatted_opening_balance
    self.opening_balance.abs unless self.errors.size > 1
  end

  def check_positive_amount
    if self.opening_balance_type.present?
      if self.opening_balance.to_f < 0 && self.opening_balance_type != "cr"
        errors.add(:opening_balance, "can't be negative or blank")
      end
    end
  end
end
