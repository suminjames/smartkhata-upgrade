# encoding: utf-8
module Models::SearchableByBranchFycode
  def self.included(base)
    base.instance_eval do
      # to keep track of the user who created and last updated the ledger
      belongs_to :branch
      scope :by_fy_code, -> (fy_code = UserSession.selected_fy_code) { where(fy_code: fy_code)}
      scope :by_branch, -> (branch_id) { where(branch_id: branch_id)}
      scope :by_branch_fy_code, ->(branch_id = UserSession.selected_branch_id, fy_code = UserSession.selected_fy_code) do
        if branch_id == 0
          where(fy_code: fy_code)
        else
          where(branch_id: branch_id, fy_code: fy_code)
        end
      end
    end
  end
end