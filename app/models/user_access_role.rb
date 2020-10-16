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
#  access_level  :integer        default: 0

class UserAccessRole < ApplicationRecord
  has_many :menu_permissions, dependent: :destroy
  has_many :menu_items, through: :menu_permissions

  validates :role_name, presence: true
  validates :role_name, uniqueness: true
  enum  role_type: { employee: 0, user: 1 }
  enum  access_level: { read_only: 0, read_and_write: 1 }

  has_many :users

  def self.access_level_types_select
    self.access_levels.keys.map { |x| [x.titleize, x] }
  end
end
