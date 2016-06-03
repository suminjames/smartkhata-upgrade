# encoding: utf-8
module Models::UpdaterWithBranchFycode

  include FiscalYearModule

  def self.included(base)
    base.instance_eval do
      before_create :set_creator, :add_branch_fycode
      before_save :set_updater

      # to keep track of the user who created and last updated the ledger
      belongs_to :creator,  class_name: 'User'
      belongs_to :updater,  class_name: 'User'
    end

  end

  private

  def set_updater
    self.updater_id = UserSession.id
  end

  def set_creator
    self.creator_id = UserSession.id
  end

  def add_branch_fycode
    self.branch_id ||= UserSession.branch_id
    self.fy_code ||= get_fy_code
  end
end