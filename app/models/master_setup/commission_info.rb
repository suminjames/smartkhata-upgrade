class MasterSetup::CommissionInfo < ActiveRecord::Base

  ########################################
  # Relationships
  has_many :commission_details, class_name: '::MasterSetup::CommissionDetail', foreign_key: 'master_setup_commission_info_id'
  accepts_nested_attributes_for :commission_details

  ########################################
  # Callbacks

  ########################################
  # Vaidations
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

  private

  def validate_date_range
    commission_info_latest = self.class.all.order(:start_date => :desc).first
    if start_date >= end_date
      errors.add :start_date, "Start date should be before the end date"
      return
    end

    if commission_info_latest.present?
      errors.add :base, "Entry missing for dates before the starting date" if self.start_date.yesterday != commission_info_latest.end_date
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


    # all should be unique
    errors.add :base, "Invalid Data" if starting_amounts.size > starting_amounts.uniq.size
    errors.add :base, "Invalid Data" if limit_amounts.size > limit_amounts.uniq.size
    errors.add :base, "At least one detail should be present and have min amount" if starting_amounts[0] != 0
    errors.add :base, "At least one detail should address the max amount" if limit_amounts[-1] != MAX

    starting_amounts = starting_amounts.drop(1)
    limit_amounts.pop
    errors.add :base, "Invalid Data" if limit_amounts != starting_amounts

  end
end
