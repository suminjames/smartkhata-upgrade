# encoding: utf-8
# TODO how to remove the code repetition
module Models::UpdaterWithBranch

  include FiscalYearModule

  def self.included(base)
    base.instance_eval do
      before_create :set_creator, :add_branch
      before_save :set_updater, :add_branch

      # to keep track of the user who created and last updated the ledger
      belongs_to :creator,  class_name: 'User'
      belongs_to :updater,  class_name: 'User'

      scope :by_branch_id, ->(branch_id = UserSession.selected_branch_id) do
        if branch_id != 0
          where(branch_id: branch_id)
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

  def add_branch
    self.branch_id ||= get_branch_id_from_session
  end

  def get_branch_id_from_session
    UserSession.selected_branch_id == 0 ? UserSession.branch_id : UserSession.selected_branch_id
  end
end