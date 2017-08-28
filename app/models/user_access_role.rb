# == Schema Information
#
# Table name: user_access_roles
#
#  id          :integer          not null, primary key
#  role_type   :integer          default(0)
#  role_name   :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class UserAccessRole < ActiveRecord::Base
  has_many :menu_permissions, dependent: :destroy
  has_many :menu_items, through: :menu_permissions

  validates_presence_of :role_name
  validates :role_name, uniqueness: true
  enum  role_type: [:employee, :user]
  enum  access_level: [:read_only, :read_and_write]

  has_many :users

  def self.access_level_types_select
    self.access_levels.keys.map {|x| [x.titleize, x]}
  end
end
