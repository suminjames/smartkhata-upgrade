# == Schema Information
#
# Table name: ledger
#
#  id                         :integer          not null, primary key
#  transaction_id             :string
#  ac_code                    :string
#  sub_code                   :string
#  voucher_code               :string
#  voucher_no                 :string
#  serial_no                  :string
#  particulars                :string
#  amount                     :string
#  nrs_amount                 :string
#  transaction_type           :string
#  transaction_date           :string
#  effective_transaction_date :string
#  bs_date                    :string
#  book_code                  :string
#  internal_no                :string
#  currency_code              :string
#  conversion_rate            :string
#  cost_revenue_code          :string
#  record_deleted             :string
#  cheque_no                  :string
#  invoice_no                 :string
#  vou_period                 :string
#  against_ac_code            :string
#  against_sub_code           :string
#  fiscal_year                :string
#  bill_no                    :string
#  particular_id              :integer
#

class Mandala::Ledger < ApplicationRecord
  self.table_name = "ledger"
  belongs_to :particular

  def new_smartkhata_particular(voucher_id, attrs = {})
    fy_code = attrs[:fy_code]
    ::Particular.unscoped.new(
      description: particulars,
      transaction_date: Date.parse(effective_transaction_date),
      ledger_id: self.ledger_id,
      amount: nrs_amount,
      transaction_type: self.sk_transaction_type,
      fy_code: fy_code,
      voucher_id: voucher_id
    )
  end

  def ledger_id
    Mandala::ChartOfAccount.where(ac_code: self.ac_code).first.find_or_create_ledger.id
  end

  def client_accounts
    Mandala::CustomerRegistration.where(ac_code: self.ac_code)
  end

  def sk_transaction_type
    self.transaction_type == 'DR' ? ::Particular.transaction_types['dr'] : ::Particular.transaction_types['cr']
  end
end
