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

  def interest_period
    start_date..end_date
  end

  private

  def validate_interest_rate_overlap
    other_interest_rates = InterestRate.all
    is_overlapping = other_interest_rates.any? do |oir|
      interest_period.overlaps?(oir.interest_period) && interest_type == oir.interest_type
    end
    errors.add :start_date, "A interest rate record in the given date range already exists!" if is_overlapping
  end

  def validate_date_range
    errors.add :start_date, "Start date should be before the end date" if start_date >= end_date
  end
end

