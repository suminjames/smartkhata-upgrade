# == Schema Information
#
# Table name: menu_permissions
#
#  id           :integer          not null, primary key
#  creator_id   :integer
#  updater_id   :integer
#  menu_item_id :integer
#  user_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class MenuPermission < ActiveRecord::Base
  include ::Models::Updater
  belongs_to :menu_item
end
