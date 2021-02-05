class AddEsewaPaymentIdToBills < ActiveRecord::Migration
  def change
    add_reference :bills, :esewa_payment, index: true, foreign_key: true
  end
end
