class MasterSetup::CommissionInfo < ActiveRecord::Base
  has_many :master_setup_commission_details
end
