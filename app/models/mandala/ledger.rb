class Mandala::Ledger < ActiveRecord::Base
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