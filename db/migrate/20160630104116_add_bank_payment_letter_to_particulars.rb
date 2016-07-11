class AddBankPaymentLetterToParticulars < ActiveRecord::Migration
  def change
    add_column :particulars, :bank_payment_letter_id, :integer, index: true
  end
end
