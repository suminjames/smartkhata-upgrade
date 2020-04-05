# encoding: utf-8
# TODO how to remove the code repetition
module Models::UpdaterWithBranch

  include FiscalYearModule

  def self.included(base)
    base.instance_eval do
      before_validation :set_creator, :set_updater
      validates_presence_of :branch_id, :creator_id, :updater_id
      # to keep track of the user who created and last updated the ledger
      belongs_to :creator,  class_name: 'User'
      belongs_to :updater,  class_name: 'User'
      belongs_to :branch

      attr_accessor :current_user_id

      scope :by_branch_id, ->(branch_id) do
        if branch_id != 0
          where(branch_id: branch_id)
        end
      end
    end
  end

  private

  def set_updater
    self.updater_id = current_user_id if current_user_id.present?
  end

  def set_creator
    self.creator_id ||= current_user_id
  end
end
