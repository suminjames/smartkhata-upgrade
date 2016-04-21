# == Schema Information
#
# Table name: employee_client_associations
#
#  id                  :integer          not null, primary key
#  employee_account_id :integer
#  client_account_id   :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class EmployeeClientAssociation < ActiveRecord::Base
  belongs_to :employee_account
  belongs_to :client_account

  def self.delete_previous_associations_for(employee_account_id)
    self.destroy_all(employee_account_id: "#{employee_account_id}")
  end
end
