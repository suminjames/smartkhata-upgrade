class Bank < ActiveRecord::Base
  has_many :bank_accounts
  validates :bank_code, uniqueness: true
end
