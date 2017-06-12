# == Schema Information
#
# Table name: menu_items
#
#  id                      :integer          not null, primary key
#  name                    :string
#  path                    :string
#  hide_on_main_navigation :boolean          default(FALSE)
#  request_type            :integer          default(0)
#  code                    :string
#  ancestry                :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#



class MenuItem < ActiveRecord::Base
  include Auditable
  has_ancestry
  # belongs_to :parent, :class_name => 'MenuItem'
  # has_many :children, :class_name => 'MenuItem', foreign_key: 'parent_id'
  has_many :menu_permissions

  # scope :black_listed_for_user, ->(user_id) { includes(:menu_permissions).where('menu_permissions.id' => nil, 'menu_permissions.user_id' => user_id) }

  # # scope :with_no_childrens
  # scope :having_childrens, -> { includes(:children).where.not(children_menu_items: {id: nil}) }
  # scope :first_level_menu_items, -> { where(parent_id: nil) }
[]
  enum request_type: [:get, :post]
  validates_uniqueness_of :code

  # TODO(subas) optimize this code block
  def self.black_listed_paths_for_user(user_access_role_id)
    permitted_ids = MenuPermission.where(user_access_role_id: user_access_role_id).pluck(:menu_item_id)
    MenuItem.where.not(id: permitted_ids).pluck(:path).to_a
  end
end
