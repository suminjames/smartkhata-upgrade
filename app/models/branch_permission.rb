# == Schema Information
#
# Table name: branch_permissions
#
#  branch_id  :integer
#  user_id    :integer
#  creator_id :integer
#  updater_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  id         :integer          not null, primary key
#

class BranchPermission < ActiveRecord::Base
  include ::Models::Updater
  belongs_to :branch
  include Auditable

  def self.delete_previous_permissions_for(user_id)
    BranchPermission.where(user_id: user_id).delete_all
  end
end
