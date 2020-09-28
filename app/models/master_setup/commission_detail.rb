  # == Schema Information
#
# Table name: master_setup_commission_details
#
#  id                              :integer          not null, primary key
#  start_amount                    :decimal(15, 4)
#  limit_amount                    :decimal(15, 4)
#  commission_rate                 :float
#  commission_amount               :float
#  master_setup_commission_info_id :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

class MasterSetup::CommissionDetail < ActiveRecord::Base
  # belongs_to :master_setup_commission_info
  ########################################
  # Constants
  MAX = 99999999999
  MIN = 0


  ########################################
  # Callbacks
  before_validation :set_max_min_amount

  ########################################
  # Vaidations
  validates_presence_of :start_amount, unless: :limit_amount?
  validates_presence_of :limit_amount, unless: :start_amount?
  validates_presence_of :commission_rate, unless: :commission_amount?
  validate :validate_amounts
  ########################################
  # Methods
  private
  def validate_amounts
    if self.start_amount > self.limit_amount
      errors.add :start_amount, "Starting price cant be less than the limit"
    end
  end

  def set_max_min_amount
    self.limit_amount = MAX if self.limit_amount.blank?
    self.start_amount = 0 if self.start_amount.blank?
  end
end
