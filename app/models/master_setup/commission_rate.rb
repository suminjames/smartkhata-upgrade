# == Schema Information
#
# Table name: master_setup_commission_rates
#
#  id           :integer          not null, primary key
#  date_from    :date
#  date_to      :date
#  amount_gt    :decimal(, )
#  amount_lt_eq :decimal(, )
#  rate         :decimal(, )
#  is_flat_rate :boolean
#  remarks      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class MasterSetup::CommissionRate < ActiveRecord::Base
  validates_presence_of :date_from, :rate, :is_flat_rate
end
