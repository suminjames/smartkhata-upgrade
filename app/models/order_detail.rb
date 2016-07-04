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
  belongs_to :isin_info

  enum state: [:cancelled, :executed, :queued]

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
