class Mandala::ReceiptPaymentSlip < ActiveRecord::Base
  self.table_name = "receipt_payment_slip"
  belongs_to :settlement

  def receipt_payment_details
    Mandala::ReceiptPaymentDetail.where(fiscal_year: self.fiscal_year, slip_type: self.slip_type, slip_no: self.slip_no )
  end
end