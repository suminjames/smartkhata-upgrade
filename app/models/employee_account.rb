class EmployeeAccount < ActiveRecord::Base
  include ::Models::Updater
  has_many :employee_client_associations
  has_many :client_accounts, through: :employee_client_associations

  # to keep track of the user who created and last updated the ledger
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User'

  # defines employee association with clients
  enum has_access_to: [:everyone, :some, :nobody]
  accepts_nested_attributes_for :employee_client_associations

  scope :find_by_employee_name, -> (name) { where("name ILIKE ?", "%#{name}%") }
end
