class Mandala::ReceiptPaymentDetail < ActiveRecord::Base
  self.table_name = "receipt_payment_detail"
  belongs_to :cheque_entry
end