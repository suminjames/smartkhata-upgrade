# == Schema Information
#
# Table name: orders
#
#  id                :integer          not null, primary key
#  order_id          :integer
#  isin_info_id      :integer
#  client_account_id :integer
#  price             :decimal(, )
#  quantity          :integer
#  amount            :decimal(, )
#  pending_quantity  :integer
#  order_time        :time
#  order_date        :date
#  order_type        :integer
#  order_segment     :integer
#  order_condition   :integer
#  order_state       :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null

class Order < ActiveRecord::Base
belongs_to :client_account 
belongs_to :isin_info
#TODO(sarojk): Find out all enums for order_state
enum order_state: [:cancelled, :executed, :queued]
#TODO(sarojk): Find out all enums for order_type
enum order_type: [:buy, :sell]
#TODO(sarojk): Find out what is an order_segment? Possible values?
#TODO(sarojk): Find out what is an order_condition? Possible values?

#TODO(sarojk): Implement Find by OrderSegment, OrderCondition, OrderState?
scope :find_by_order_type, -> (type) { where(order_type: order_types[:"#{type}"]) }
#  TODO: Implement multi-name search
#scope :find_by_client_name, -> (name) { includes(:client_account).where(client_account: {"client_name ILIKE ?", "%#{name}%"}) }
# scope :find_by_client_name, -> (name) { includes(:client_account).references(:client_accounts).where(client_account: {id: 1}) }
scope :find_by_order_id, -> (id) { where("order_id" => "#{id}") }
scope :find_by_date, -> (date) { where(
  :date => date.beginning_of_day..date.end_of_day) }
scope :find_by_date_range, -> (date_from, date_to) { where(
  :date => date_from.beginning_of_day..date_to.end_of_day) }
end
