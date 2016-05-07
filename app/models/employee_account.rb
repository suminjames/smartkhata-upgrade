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
