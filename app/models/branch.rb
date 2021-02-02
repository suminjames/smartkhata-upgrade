# == Schema Information
#
# Table name: branches
#
#  id         :integer          not null, primary key
#  code       :string
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Branch < ApplicationRecord
  validates :code, :address, presence: true
  validates :code, uniqueness: { case_sensitive: false }
  include Auditable
  def code=(val)
    self[:code] = val.try(
      :upcase
    )
  end

  def self.permitted_branches_for_user(user)
    # TODO(subas) self branch should be allowed
    branches = []
    if user.present?
      permitted_ids = BranchPermission.where(user_id: user.id).pluck(:branch_id)
      branches = Branch.where(id: permitted_ids)
      branches = Branch.all if user.admin?
      branches = branches.to_a
      branches << Branch.new(code: 'ALL', id: 0) if branches.size == Branch.all.count
    end
    branches
  end

  def self.has_multiple_branches?
    Branch.unscoped.size > 1
  end

  def self.selected_branch(selected_branch_id)
    Branch.find_by(id: selected_branch_id)
  end
end
