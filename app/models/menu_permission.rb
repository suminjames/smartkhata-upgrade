# == Schema Information
#
# Table name: menu_permissions
#
#  id                  :integer          not null, primary key
#  creator_id          :integer
#  updater_id          :integer
#  menu_item_id        :integer
#  user_access_role_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class MenuPermission < ActiveRecord::Base
  include ::Models::Updater
  belongs_to :menu_item

  def self.delete_previous_permissions_for(user_id)
    MenuPermission.where(user_id: user_id).delete_all
  end
end
