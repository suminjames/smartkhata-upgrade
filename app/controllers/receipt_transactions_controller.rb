class ReceiptTransactionsController < ApplicationController
  before_action -> {authorize ReceiptTransaction}, only: [:index]

  def index
    @receipt_transactions = ReceiptTransaction.order(created_at: :desc)
  end
end