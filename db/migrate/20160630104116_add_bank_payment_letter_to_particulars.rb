class AddBankPaymentLetterToParticulars < ActiveRecord::Migration[4.2]
  def change
    add_column :particulars, :bank_payment_letter_id, :integer, index: true
  end
end
