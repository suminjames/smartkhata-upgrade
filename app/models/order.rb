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
  include Auditable
  extend CustomDateModule
  belongs_to :client_account
  has_many :order_details

  validates_presence_of :client_account_id

  # TODO(sarojk): Implement find by OrderSegment, OrderCondition, OrderState?
  scope :find_by_order_type, -> (type) { where(order_type: order_types[:"#{type}"]) }

  scope :find_by_order_number, -> (number) { where("order_number" => "#{number}") }

  scope :find_by_date, -> (date) { where(
      :date => date.beginning_of_day..date.end_of_day) }

  scope :find_by_date_range, -> (date_from, date_to) { where(:date => date_from.beginning_of_day..date_to.end_of_day) }

  # filterrific integration
  filterrific(
    default_filter_params: { sorted_by: 'id_asc' },
    available_filters: [
      :sorted_by,
      :by_date,
      :by_date_from,
      :by_date_to,
      :by_client_id,
      :by_order_number
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^id/
        order("orders.id #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :by_date, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where(:date => date_ad.beginning_of_day..date_ad.end_of_day)
  }
  scope :by_date_from, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('date >= ?', date_ad.beginning_of_day).order(id: :asc)
  }
  scope :by_date_to, lambda { |date_bs|
    date_ad = bs_to_ad(date_bs)
    where('date <= ?', date_ad.end_of_day).order(id: :asc)
  }
  scope :by_client_id,    -> (id)  { where(client_account_id: id).order(id: :asc) }
  scope :by_order_number, -> (num) { where(order_number: num).order(id: :asc) }
end
