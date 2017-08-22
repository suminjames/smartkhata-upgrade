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



class OrderDetail < ActiveRecord::Base
  include Auditable
  belongs_to :isin_info
  belongs_to :order

  validates_presence_of :isin_info_id
  validates_presence_of :order_id
  validates_length_of :order_nepse_id, :minimum => 5

  # As enum type 'new' is reserved for new object creation, used 'neww' instead.
  enum state: [:cancelled, :executed, :queued, :neww]

  enum typee: [:buy, :sell]

  # ct: continous trade
  # atc: at the time of closing
  # ato: at the time of opening
  enum segment: [:ct, :atc, :ato]

  #TODO(sarojk): Find out what is a condition? Possible values?
  # none is reserved, so resorted to 'nonee'
  # ioc: immediate or cancel
  # fok: fill or kill
  # aon: all or none
  enum condition: [:nonee, :aon, :ioc, :fok]
end
