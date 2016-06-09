
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

  #TODO(sarojk): Find out all enums for state
  # 10512 rows of test file only contained one of values 'cancelled', 'executed', or 'queued'
  enum state: [:cancelled, :executed, :queued]

  #TODO(sarojk): Find out all enums for type
  # 10512 rows of test file only contained one of values 'buying' or 'selling'
  enum typee: [:buy, :sell]

  #TODO(sarojk): Find out what is a segment? Possible values?
  enum segment: [:ct]

  #TODO(sarojk): Find out what is a condition? Possible values?
  # 'none' is reserved, so resorted to 'nonee'
  enum condition: [:nonee, :aon]
end
