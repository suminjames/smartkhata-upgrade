# encoding: utf-8
# TODO how to remove the code repetition
module Models::UpdaterWithBranch

  include FiscalYearModule

  def self.included(base)
    base.instance_eval do
      before_create :set_creator, :add_branch
      before_save :set_updater
    end
  end

  private

  def set_updater
    self.updater_id = UserSession.id
  end

  def set_creator
    self.creator_id = UserSession.id
  end

  def add_branch
    self.branch_id ||= UserSession.branch_id
  end
end