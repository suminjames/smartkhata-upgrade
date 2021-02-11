# == Schema Information
#
# Table name: order_details
#
#  id               :integer          not null, primary key
#  order_id         :integer
#  order_nepse_id   :string
#  isin_info_id     :integer
#  price            :decimal(, )
#  quantity         :integer
#  amount           :decimal(, )
#  pending_quantity :integer
#  typee            :integer
#  segment          :integer
#  condition        :integer
#  state            :integer
#  date_time        :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class OrderDetail < ApplicationRecord
  #include Auditable
  belongs_to :isin_info
  belongs_to :order

  # belongs_to rails 5
  # validates_presence_of :isin_info_id
  # validates_presence_of :order_id
  validates :order_nepse_id, length: { minimum: 5 }

  # As enum type 'new' is reserved for new object creation, used 'neww' instead.
  enum state: { cancelled: 0, executed: 1, queued: 2, neww: 3 }

  enum typee: { buy: 0, sell: 1 }

  # ct: continous trade
  # atc: at the time of closing
  # ato: at the time of opening
  enum segment: { ct: 0, atc: 1, ato: 2 }

  #TODO(sarojk): Find out what is a condition? Possible values?
  # none is reserved, so resorted to 'nonee'
  # ioc: immediate or cancel
  # fok: fill or kill
  # aon: all or none
  enum condition: { nonee: 0, aon: 1, ioc: 2, fok: 3 }
end
