# == Schema Information
#
# Table name: banks
#
#  id         :integer          not null, primary key
#  name       :string
#  bank_code  :string
#  address    :string
#  contact_no :string
#  creator_id :integer
#  updater_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Bank < ApplicationRecord
  include Auditable
  include ::Models::Updater
  has_many :bank_accounts

  attr_accessor :skip_name_validation

  validates :name, uniqueness: true, presence: true, unless: :skip_name_validation
  validates :bank_code, uniqueness: true, presence: true

  def code_and_name
    "#{self.bank_code} (#{self.name})"
  end
end
