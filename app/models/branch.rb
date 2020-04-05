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



class Branch < ActiveRecord::Base
  validates_presence_of :code, :address
  validates :code, uniqueness: {case_sensitive: false}
  include Auditable
  def code=(val)
    write_attribute :code, val.try(
      :upcase)
  end

  def self.permitted_branches_for_user(user)
    # TODO(subas) self branch should be allowed
    branches = []
    if user.present?
      permitted_ids = BranchPermission.where(user_id: user.id).pluck(:branch_id)
      branches = Branch.where(id: permitted_ids).to_a
      branches = Branch.all.to_a if user.admin?
      if branches.size == Branch.all.count
        branches << Branch.new(code: 'ALL', id: 0)
      end
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
