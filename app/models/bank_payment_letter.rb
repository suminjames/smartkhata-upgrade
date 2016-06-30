class BankPaymentLetter < ActiveRecord::Base
  belongs_to :sales_settlement
  belongs_to :branch
  belongs_to :voucher
end
