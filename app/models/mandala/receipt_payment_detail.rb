class Mandala::ReceiptPaymentDetail < ActiveRecord::Base
  self.table_name = "receipt_payment_detail"
  belongs_to :cheque_entry

  def new_smartkhata_cheque_entry(date, fy_code)
    ::ChequeEntry.new(
                     cheque_number: cheque_no,
                     additional_bank_id: bank_id(bank_code),
                     beneficiary_name: beneficiary_name,
                     cheque_issued_type: cheque_issued_type,
                     status: :approved,
                     print_status: :printed,
                     cheque_date: date,
                     fy_code: fy_code,
                     amount: amount,
                     client_account_id: beneficiary_client_id
    ) if ( !cheque_no.blank? && valid_cheque?)
  end

  def find_cheque_entry
    cheque_entry = ::ChequeEntry.where(cheque_number: cheque_no, additional_bank_id: bank_id(bank_code))
  end

  def beneficiary_name
    Mandala::ChartOfAccount.where(ac_code: self.customer_code).first.ac_name
  end

  def beneficiary_client_id
    Mandala::ChartOfAccount.where(ac_code: self.customer_code).first.ledger.client_account_id
  end

  def bank_id(bank_code)
    bank = Bank.find_by(bank_code: bank_code)
    unless bank.present?
      bank = Bank.create!(bank_code: bank_code, name: "Unknown", skip_name_validation: true)
    end  
    bank.id
  end

  def cheque_issued_type
    self.slip_type == 'R' ? ::ChequeEntry.cheque_issued_types[:receipt] : ::ChequeEntry.cheque_issued_types[:payment]
  end

  def valid_cheque?
      /\A[-+]?\d+\z/ === cheque_no && cheque_no != 'cash'
  end
end