# encoding: utf-8
# TODO how to remove the code repetition
module Models::UpdaterWithFyCode

  include FiscalYearModule

  def self.included(base)
    base.instance_eval do
      before_create :set_creator, :add_fy_code
      before_save :set_updater,:add_fy_code

      # to keep track of the user who created and last updated the ledger
      belongs_to :creator,  class_name: 'User'
      belongs_to :updater,  class_name: 'User'
      scope :by_fy_code, -> (fy_code = UserSession.selected_fy_code) { where(fy_code: fy_code)}

      # default_scope {where(fy_code = UserSession.selected_fy_code)}
      scope :by_branch_fy_code, ->(branch_id = UserSession.selected_branch_id, fy_code = UserSession.selected_fy_code) do
        if branch_id == 0
          where(fy_code: fy_code)
        else
          where(branch_id: branch_id, fy_code: fy_code)
        end
      end

      # scope for balances
      # because for balance we are taking the one with no branch at all
      scope :by_branch_fy_code_for_balance, ->(branch_id = UserSession.selected_branch_id, fy_code = UserSession.selected_fy_code) do
        if branch_id == 0
          where(branch_id: nil, fy_code: fy_code)
        else
          where(branch_id: branch_id, fy_code: fy_code)
        end
      end

    end
  end

  private

  def set_updater
    self.updater_id = UserSession.id
  end

  def set_creator
    self.creator_id = UserSession.id
  end

  def add_fy_code
    self.fy_code ||= get_fy_code
  end
end