class EmployeeAccount < ActiveRecord::Base
  has_many :employee_client_associations
  has_many :client_accounts, through: :employee_client_associations

  # defines employee association with clients
  enum has_access_to: [:everyone, :some, :nobody]
  accepts_nested_attributes_for :employee_client_associations

  scope :find_by_employee_name, -> (name) { where("name ILIKE ?", "%#{name}%") }
end
