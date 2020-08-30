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
  
  scope :by_interest_type, ->(interest_type) { where(interest_type: InterestRate.interest_types[interest_type]) }
  scope :for_date, -> (date) { where('start_date <= ? AND end_date >= ?', date, date) }

  def self.get_rate(date, interest_type)
    InterestRate.for_date(date).by_interest_type(interest_type).first&.rate
  end
  
  private

  def validate_interest_rate_overlap
    date_range_sql = ":end_date >= start_date and end_date >= :start_date"
    interest_rate_records = InterestRate.where(interest_type: InterestRate.interest_types[interest_type])
    is_overlapping = interest_rate_records.where(date_range_sql, start_date: start_date, end_date: end_date).exists?
    errors.add :start_date, "An interest rate record in the given date range already exists!" if is_overlapping
  end

  def validate_date_range
    return if start_date.blank? || end_date.blank?
    errors.add :start_date, "Start date should be before the end date" if start_date >= end_date
  end
end

