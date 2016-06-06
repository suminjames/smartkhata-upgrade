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


class Bank < ActiveRecord::Base
  include ::Models::Updater
  has_many :bank_accounts
  validates :name, uniqueness: true, presence: true
  validates :bank_code, uniqueness: true
end
