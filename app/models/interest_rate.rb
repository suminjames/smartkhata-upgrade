# == Schema Information
#
# Table name: interest_rates
#
#  id            :integer          not null, primary key
#  start_date    :date
#  end_date      :date
#  interest_type :integer
#  rate          :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class InterestRate < ActiveRecord::Base
  
  validates_inclusion_of :rate, in: 1..100, message: "Rate should lie between 1 and 100."
  validate :validate_date_range
  
  enum interest_type: %i[payable receivable]
  
  private
  
  def validate_date_range
    errors.add :start_date, "Start date should be before the end date" if start_date >= end_date
  end
end
