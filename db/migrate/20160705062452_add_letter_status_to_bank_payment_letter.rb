class AddLetterStatusToBankPaymentLetter < ActiveRecord::Migration
  def change
    add_column :bank_payment_letters, :letter_status, :integer, index: true, default: 0
    add_column :bank_payment_letters, :reviewer_id, :integer, index: true, default: 0
  end
end
