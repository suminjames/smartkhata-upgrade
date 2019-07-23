# encoding: utf-8
module Models::UpdaterWithBranchFycodeBalance

  include FiscalYearModule

  def self.included(base)
    base.instance_eval do
      before_validation :set_creator
      before_validation :set_updater
      # to keep track of the user who created and last updated the ledger
      belongs_to :creator,  class_name: 'User'
      belongs_to :updater,  class_name: 'User'
      belongs_to :branch

      validates_presence_of :creator_id, :updater_id
      scope :by_fy_code, -> (fy_code) { where(fy_code: fy_code)}
      scope :by_fy_code_org, -> (fy_code) { where(fy_code: fy_code, branch_id: nil)}
      scope :by_branch, -> (branch_id) { where(branch_id: branch_id)}

      attr_accessor :current_user_id
      # # scope based on the branch and fycode selection
      # default_scope do
      #   if UserSession.selected_branch_id == 0
      #     where(fy_code: UserSession.selected_fy_code)
      #   else
      #     where(branch_id: UserSession.selected_branch_id, fy_code: UserSession.selected_fy_code)
      #   end
      # end

      # for non balance records
      # use this for read only
      # TODO(SUBAS) stupid mistake of using default scope here
      scope :by_branch_fy_code, ->(fy_code, branch_id) do
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
    self.updater_id = current_user_id
  end

  def set_creator
    self.creator_id ||= current_user_id
  end
  #
  # def add_fy_code
  #   # self.branch_id ||= get_branch_id_from_session
  #   self.fy_code ||= get_fy_code
  # end
  #
  # def get_branch_id_from_session
  #   UserSession.selected_branch_id == 0 ? nil : UserSession.selected_branch_id
  # end

end
