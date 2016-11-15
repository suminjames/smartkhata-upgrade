class MasterSetup::CommissionInfo < ActiveRecord::Base

  ########################################
  # Relationships
  has_many :commission_details, class_name: '::MasterSetup::CommissionDetail', foreign_key: 'master_setup_commission_info_id'
  accepts_nested_attributes_for :commission_details

  ########################################
  # Callbacks

  ########################################
  # Vaidations
  validate :validate_details

  ########################################
  # Scopes

  ########################################
  # Methods

  private

  def validate_details
  end
end
