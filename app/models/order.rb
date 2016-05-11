# == Schema Information
#
# Table name: orders
#
#  id                :integer          not null, primary key
#  order_number      :integer
#  client_account_id :integer
#  fy_code           :integer
#  date              :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Order < ActiveRecord::Base
  belongs_to :client_account
  has_many :order_details

  # TODO(sarojk): Implement find by OrderSegment, OrderCondition, OrderState?
  scope :find_by_order_type, -> (type) { where(order_type: order_types[:"#{type}"]) }

  # TODO(sarojk): Implement multi-name search
  scope :find_by_client_name, -> (name) { includes(:client_account).where("client_accounts.name ILIKE ?",  "%#{name}%" ).references(:client_accounts) }

  scope :find_by_client_id, -> (id) { includes(:client_account).where("client_accounts.id = ?",  id).references(:client_accounts) }

  scope :find_by_order_number, -> (number) { where("order_number" => "#{number}") }

  scope :find_by_date, -> (date) { where(
      :date => date.beginning_of_day..date.end_of_day) }

  scope :find_by_date_range, -> (date_from, date_to) { where( :date => date_from.beginning_of_day..date_to.end_of_day) }

end
