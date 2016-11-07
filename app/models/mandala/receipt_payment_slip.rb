class Mandala::ReceiptPaymentSlip < ActiveRecord::Base
  self.table_name = "receipt_payment_slip"
  belongs_to :settlement

  def receipt_payment_details
    Mandala::ReceiptPaymentDetail.where(fiscal_year: self.fiscal_year, slip_type: self.slip_type, slip_no: self.slip_no )
  end

  def new_smartkhata_settlement(voucher_id, fy_code)
    ::Settlement.unscoped.new(
                             amount: amount,
                             name: self.beneficiary_name,
                             date: Date.parse(self.slip_date),
                             settlement_type: self.settlement_type,
                             voucher_id: voucher_id,
                             fy_code: fy_code
    )
  end

  def beneficiary_name
    Mandala::ChartOfAccount.where(ac_code: self.customer_code).first.ac_name
  end

  def settlement_type
    self.slip_type == 'P' ? ::Settlement.settlement_types['payment'] : ::Settlement.settlement_types['receipt']
  end
end