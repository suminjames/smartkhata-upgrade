class MasterSetup::CommissionDetail < ActiveRecord::Base
  # belongs_to :master_setup_commission_info

  ########################################
  # Vaidations
  validates_presence_of :start_amount, :limit_amount
end
