class EmployeeClientAssociation < ActiveRecord::Base
  belongs_to :employee_account
  belongs_to :client_account

  def self.delete_previous_associations_for(employee_account_id)
    self.destroy_all(employee_account_id: "#{employee_account_id}")
  end
end
