# == Schema Information
#
# Table name: receipt_payment_slip
#
#  id             :integer          not null, primary key
#  title          :string
#  customer_code  :string
#  currency_code  :string
#  amount         :string
#  entered_by     :string
#  entered_date   :string
#  fiscal_year    :string
#  remarks        :string
#  payment_type   :string
#  ac_code        :string
#  slip_no        :string
#  slip_date      :string
#  slip_type      :string
#  manual_slip_no :string
#  settlement_tag :string
#  voucher_no     :string
#  voucher_code   :string
#  supplier_id    :string
#  transaction_no :string
#  void           :string
#  bill_no        :string
#  pay_to         :string
#  cheque_printed :string
#  issue_date     :string
#  settlement_id  :integer
#

class Mandala::ReceiptPaymentSlip < ApplicationRecord
  self.table_name = "receipt_payment_slip"
  belongs_to :settlement

  def receipt_payment_details
    Mandala::ReceiptPaymentDetail.where(fiscal_year: self.fiscal_year, slip_type: self.slip_type, slip_no: self.slip_no)
  end

  def new_smartkhata_settlement(voucher_id, fy_code)
    ::Settlement.unscoped.new(
      amount: amount,
      name: self.beneficiary_name,
      date: Date.parse(self.slip_date),
      settlement_type: self.settlement_type,
      voucher_id: voucher_id,
      fy_code: fy_code,
      branch_id: 1
    )
  end

  def beneficiary_name
    Mandala::ChartOfAccount.where(ac_code: self.customer_code).first.ac_name
  end

  def settlement_type
    self.slip_type == 'P' ? ::Settlement.settlement_types['payment'] : ::Settlement.settlement_types['receipt']
  end
end
