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
  validates_presence_of :start_date, :end_date

  validate :validate_date_range
  validate :validate_interest_rate_overlap

  enum interest_type: %i[payable receivable]

  private

  def validate_interest_rate_overlap
    range_sql = ":end_date >= start_date and end_date >= :start_date"
    interest_rates_all = InterestRate.where(interest_type: InterestRate.interest_types[interest_type])
    is_overlapping = interest_rates_all.where(range_sql, start_date: start_date, end_date: end_date).exists?
    errors.add :start_date, "A interest rate record in the given date range already exists!" if is_overlapping
  end

  def validate_date_range
    errors.add :start_date, "Start date should be before the end date" if start_date >= end_date
  end
end

