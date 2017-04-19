# service to settle closeout
class CloseoutSettlementService
  attr_reader :share_transaction, :error, :settlement_by, :balancing_transactions

  SETTLEMENT_TYPES = %w(client broker)

  def initialize( transaction, settlement_by, params={})
    @share_transaction = transaction
    @error = nil
    @settlement_by = settlement_by
    @balancing_transactions_ids = params[:balancing_transaction_ids]
    @balancing_transactions = ShareTransaction.unscoped.where(id: @balancing_transactions_ids)
    @closeout_quantity = @share_transaction.raw_quantity -  @share_transaction.quantity
  end

  def process
    return unless validate?
    ActiveRecord::Base.transaction do
      process_sales_closeout if share_transaction.selling?
      process_buy_closeout if share_transaction.buying?
    end
  end


  def validate?
  #   settlement by allowed is only client and broker
    unless SETTLEMENT_TYPES.include?(settlement_by)
      @error = 'This is not a valid request'
      return false
    end

    # the transactions that balance the closeout should have equal quantity
    if @balancing_transactions_ids.present? && ( balancing_transactions.sum(:quantity) != @closeout_quantity)
      @error = 'This is not a valid request'
      return false
    end

    return true
  end

  def process_sales_closeout
    share_transaction.closeout_settled = true
    bill = share_transaction.bill
    if settlement_by == 'client'
      bill.net_amount -= share_transaction.closeout_amount
      bill.closeout_charge += share_transaction.closeout_amount
      bill.save!
    end
    share_transaction.save!
  end

  def process_buy_closeout
    share_transaction.closeout_settled = true

    if settlement_by == 'broker'
      # make the quantity of the balancing transactions to be zero in case it is paid by broker
      # add the quanity to the client in case it has to be hidden from the client
      # no change in bill
      share_transaction.quantity += @closeout_quantity
      balancing_transactions.each do |b|
        # also hide the particular from client for the new transactions.
        b.quantity = 0
        b.save
      end
    end

    share_transaction.save!
  end
end
