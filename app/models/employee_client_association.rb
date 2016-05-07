# == Schema Information
#
# Table name: employee_client_associations
#
#  id                  :integer          not null, primary key
#  employee_account_id :integer
#  client_account_id   :integer
#  creator_id          :integer
#  updater_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class EmployeeClientAssociation < ActiveRecord::Base
  include ::Models::Updater

  belongs_to :employee_account
  belongs_to :client_account

  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  def self.delete_previous_associations_for(employee_account_id)
    self.destroy_all(employee_account_id: "#{employee_account_id}")
  end
end
