# encoding: utf-8
module Models::UpdaterWithBranchFycode

  include FiscalYearModule

  def self.included(base)
    base.instance_eval do
      before_create :set_creator
      before_save :set_updater

      validates_presence_of :branch_id, :creator_id, :updater_id
      # to keep track of the user who created and last updated the ledger
      belongs_to :creator,  class_name: 'User'
      belongs_to :updater,  class_name: 'User'
      belongs_to :branch

      scope :by_fy_code, -> (fy_code ) { where(fy_code: fy_code)}
      scope :by_branch, -> (branch_id) { where(branch_id: branch_id)}

      attr_accessor :current_user_id


      # TODO(subas) Remove this once time comes kept here because subas had little time to analyze its effects

      scope :by_branch_fy_code, ->(branch_id , fy_code ) do
        if branch_id == 0
          where(fy_code: fy_code)
        else
          where(branch_id: branch_id, fy_code: fy_code)
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

  # def add_branch_fycode
  #   self.branch_id ||= get_branch_id_from_session
  #   self.fy_code ||= get_fy_code
  # end
  #
  # def get_branch_id_from_session
  #   UserSession.selected_branch_id == 0 ? UserSession.branch_id : UserSession.selected_branch_id
  # end

end