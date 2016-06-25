class MenuItem < ActiveRecord::Base
  belongs_to :parent, :class_name => 'MenuItem'
  has_many :children, :class_name => 'MenuItem', foreign_key: 'parent_id'
end
