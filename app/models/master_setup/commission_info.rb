# == Schema Information
#
# Table name: master_setup_commission_infos
#
#  id                    :integer          not null, primary key
#  start_date            :date
#  end_date              :date
#  start_date_bs         :string
#  end_date_bs           :string
#  nepse_commission_rate :float
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class MasterSetup::CommissionInfo < ActiveRecord::Base

  ########################################
  # Relationships
  has_many :commission_details, class_name: '::MasterSetup::CommissionDetail', foreign_key: 'master_setup_commission_info_id'
  accepts_nested_attributes_for :commission_details

  attr_accessor :commission_details_array, :broker_commission_rate
  ########################################
  # Callbacks

  ########################################
  # Validations
  validates :nepse_commission_rate, presence: true, :inclusion => {in: 0..100, message:"is out of range."}
  validate :validate_date_range
  validate :validate_details

  ########################################
  # Constants
  MAX = 99999999999
  MIN = 0


  ########################################
  # Scopes

  ########################################
  # Methods

  def is_latest?
    self == self.class.all.order(:start_date => :desc).first
  end

  private

  def validate_date_range
    # get the last commission info ordered by start date
    commission_info_latest = self.class.all.order(:start_date => :desc).first
    if start_date >= end_date
      errors.add :start_date, "Start date should be before the end date"
      return
    end

    if commission_info_latest.present?

      end_date_to_compare = commission_info_latest.end_date

      # cases where the one being edited is the last entry
      if self.id == commission_info_latest.id
        end_date_to_compare = self.start_date.yesterday
      end

      # cant have 2 commission details for same day
      # cant have dates without commission rates
      if self.start_date < commission_info_latest.end_date && self.id != commission_info_latest.id
        errors.add :base, "Date is already Included. Please review"
      elsif self.start_date.yesterday != end_date_to_compare
        errors.add :base, "Entry missing for dates before the starting date"
      end

    end
  end

  def validate_details
    starting_amounts = []
    limit_amounts = []
    self.commission_details.each do |d|
      starting_amounts << d.start_amount
      limit_amounts << d.limit_amount
    end
    starting_amounts.sort!
    limit_amounts.sort!

    # all should be unique for a date range
    # cant be validated on child model because it will be unknown to that model
    errors.add :base, "Invalid Data" if starting_amounts.size > starting_amounts.uniq.size
    errors.add :base, "Invalid Data" if limit_amounts.size > limit_amounts.uniq.size

    # should have atleast one detail
    # details should cover the whole range ie 0 - MAX
    errors.add :base, "At least one detail should be present and have min amount" if starting_amounts[0] != 0
    errors.add :base, "At least one detail should address the max amount" if limit_amounts[-1] != MAX

    # since we have two ends that can be nil
    # cases when starting amount is nil
    # or when limiting amount is nil
    # removing both should be exactly equal
    # more of a collective validation to ward off unwanted data
    starting_amounts = starting_amounts.drop(1)
    limit_amounts.pop

    errors.add :base, "Invalid Data" if limit_amounts != starting_amounts
  end
end
