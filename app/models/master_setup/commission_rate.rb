# == Schema Information
#
# Table name: master_setup_commission_rates
#
#  id                     :integer          not null, primary key
#  date_from              :date
#  date_to                :date
#  has_date_to_limit      :boolean
#  amount_gt              :decimal(, )
#  amount_lt_eq           :decimal(, )
#  has_amount_lt_eq_limit :boolean
#  rate                   :decimal(, )
#  is_flat_rate           :boolean
#  remarks                :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class MasterSetup::CommissionRate < ActiveRecord::Base

end