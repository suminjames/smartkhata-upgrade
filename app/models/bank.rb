# == Schema Information
#
# Table name: banks
#
#  id         :integer          not null, primary key
#  name       :string
#  bank_code  :string
#  address    :string
#  contact_no :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Bank < ActiveRecord::Base
  has_many :bank_accounts
  validates :bank_code, uniqueness: true
end
