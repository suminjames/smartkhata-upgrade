class ChequeEntry < ActiveRecord::Base
  belongs_to :bank_account
  belongs_to :particular
  belongs_to :voucher

  validates :cheque_number, uniqueness: { scope: :additional_bank_id, message: "should be unique" }
end
