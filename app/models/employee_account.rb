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
#  invited                   :boolean          default("false")
#  has_access_to             :integer          default("2")
#  creator_id                :integer
#  updater_id                :integer
#  user_id                   :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class EmployeeAccount < ActiveRecord::Base
  include ::Models::UpdaterWithBranch

  # An assumption that name of an Employee Account will always be unique is made. This is unlike Client Account whose uniqueness is nepse_code(or client_code in Ledger).
  # TODO(sarojk) Find a better way to implement unique identification
  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  after_create :create_ledger

  has_many :employee_ledger_associations
  has_many :ledgers, through: :employee_ledger_associations

  # defines employee association with ledgers
  enum has_access_to: [:everyone, :some, :nobody]
  accepts_nested_attributes_for :employee_ledger_associations

  scope :find_by_employee_name, -> (name) { where("name ILIKE ?", "%#{name}%") }
  scope :find_by_employee_id, -> (id) { where(id: id) }

  # create employee ledger
  def create_ledger
    employee_ledger = Ledger.find_or_create_by!(name: self.name) do |ledger|
      ledger.name = self.name
      ledger.employee_account_id = self.id
    end
  end

  # assign the employee ledger to  'Employees' group
  def assign_group(group_name)
    client_group = Group.find_or_create_by!(name: group_name)
    # append(<<) apparently doesn't append duplicate by taking care of de-duplication automatically for has_many relationships. see http://stackoverflow.com/questions/1315109/rails-idiom-to-avoid-duplicates-in-has-many-through
    employee_ledger = Ledger.find_by(employee_account_id: self.id)
    client_group.ledgers << employee_ledger
  end

end
