module Models::WithBranchFycode
  include FiscalYearModule

  def self.included(base)
    base.instance_eval do
      before_create :add_branch_fycode
      before_save :add_branch_fycode

      # to keep track of the user who created and last updated the ledger
      belongs_to :branch

      scope :by_fy_code, ->(fy_code) { where(fy_code: fy_code)}
      scope :by_branch, ->(branch_id) { where(branch_id: branch_id)}

      # TODO(subas) Remove this once time comes kept here because subas had little time to analyze its effects

      scope :by_branch_fy_code, lambda { |branch_id, fy_code|
        # if branch_id == 0
        #   unscoped.where(fy_code: fy_code)
        # else
        #   unscoped.where(branch_id: branch_id, fy_code: fy_code)
        # end
      }
    end
  end

  private

  def add_branch_fycode
    self.branch_id ||= get_branch_id_from_session
    self.fy_code ||= get_fy_code
  end

  def get_branch_id_from_session
    UserSession.selected_branch_id.zero? ? UserSession.branch_id : UserSession.selected_branch_id
  end
end
