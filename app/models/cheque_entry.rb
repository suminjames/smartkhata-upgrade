class ChequeEntry < ActiveRecord::Base
  belongs_to :bank_account
  belongs_to :particular
  belongs_to :voucher
end
