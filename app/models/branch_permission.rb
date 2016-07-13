class BranchPermission < ActiveRecord::Base
  include ::Models::Updater
  belongs_to :branch

  def self.delete_previous_permissions_for(user_id)
    BranchPermission.where(user_id: user_id).delete_all
  end
end
