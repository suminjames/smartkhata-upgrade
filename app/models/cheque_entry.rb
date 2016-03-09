class ChequeEntry < ActiveRecord::Base
  belongs_to :bank_account
  belongs_to :ledger
end
