# == Schema Information
#
# Table name: employee_accounts
#
#  id                        :integer          not null, primary key
#  name                      :string
#  address1                  :string           default(" ")
#  address1_perm             :string
#  address2                  :string           default(" ")
#  address2_perm             :string
#  address3                  :string
#  address3_perm             :string
#  city                      :string           default(" ")
#  city_perm                 :string
#  state                     :string
#  state_perm                :string
#  country                   :string           default(" ")
#  country_perm              :string
#  phone                     :string
#  phone_perm                :string
#  dob                       :string
#  sex                       :string
#  nationality               :string
#  email                     :string
#  father_mother             :string
#  citizen_passport          :string
#  granfather_father_inlaw   :string
#  husband_spouse            :string
#  citizen_passport_date     :string
#  citizen_passport_district :string
#  pan_no                    :string
#  dob_ad                    :string
#  bank_name                 :string
#  bank_account              :string
#  bank_address              :string
#  company_name              :string
#  company_id                :string
#  branch_id                 :integer
#  invited                   :boolean          default(FALSE)
#  has_access_to             :integer          default(2)
#  creator_id                :integer
#  updater_id                :integer
#  user_id                   :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class EmployeeAccount < ApplicationRecord
  include Auditable
  include ::Models::UpdaterWithBranch
  attr_accessor :user_access_role_id
  validates :name, :email, presence: true
  validates :email, uniqueness: true, format: { with: EMAIL_REGEX }

  after_create :create_ledger

  has_many :employee_ledger_associations
  has_many :ledgers, through: :employee_ledger_associations
  belongs_to :user, optional: true
  has_one :user_access_role, through: :user
  has_many :branch_permissions, through: :user

  # defines employee association with ledgers
  enum has_access_to: { everyone: 0, some: 1, nobody: 2 }
  accepts_nested_attributes_for :employee_ledger_associations

  scope :find_by_employee_name, ->(name) { where("name ILIKE ?", "%#{name}%") }
  scope :find_by_employee_id, ->(id) { where(id: id) }

  # create employee ledger
  def create_ledger
    employee_group = Group.find_or_create_by!(name: "Employees")
    Ledger.create!(name: self.name) do |ledger|
      ledger.name = self.name
      ledger.employee_account_id = self.id
      ledger.group_id = employee_group.id
    end
  end

  # assign the employee ledger to 'Employees' group
  def assign_group(group_name)
    client_group = Group.find_or_create_by!(name: group_name)
    # append(<<) apparently doesn't append duplicate by taking care of de-duplication automatically for has_many relationships. see http://stackoverflow.com/questions/1315109/rails-idiom-to-avoid-duplicates-in-has-many-through
    employee_ledger = Ledger.find_by(employee_account_id: self.id)
    client_group.ledgers << employee_ledger
  end

  #
  # Searches for employee accounts that have name similar to search_term provided.
  # Returns an array of hash(not EmployeeAccount objects) containing attributes sufficient to represent employees in combobox.
  # Attributes include id and name(identifier)
  #
  def self.find_similar_to_term(search_term)
    search_term = search_term.present? ? search_term.to_s : ''
    employee_accounts = EmployeeAccount.where("name ILIKE :search", search: "%#{search_term}%").order(:name).pluck_to_hash(:id, :name)
    employee_accounts.collect do |employee_account|
      { text: "#{employee_account['name']} (#{employee_account['id']})", id: (employee_account['id']).to_s }
    end
  end

  def user_access_role_id
    self.user_access_role.id if self.user_access_role.present?
  end

  #
  # As Employee Accounts don't have a unique identifier except for the id, append id with name.
  #
  def name_with_id
    "#{name} (#{id})"
  end
end
