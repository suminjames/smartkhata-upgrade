class MasterSetup::CommissionInfo < ActiveRecord::Base
  has_many :commission_details, class_name: '::MasterSetup::CommissionDetail', foreign_key: 'master_setup_commission_info_id'
end
