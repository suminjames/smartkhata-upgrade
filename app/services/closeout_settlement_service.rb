# service to settle closeout
class CloseoutSettlementService
  include ApplicationHelper
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
    company_symbol = share_transaction.isin_info.isin
    share_rate = share_transaction.share_rate
    client_account = share_transaction.client_account
    client_name = client_account.name
    cost_center_id = client_account.branch_id
    settlement_date = Time.now
    closeout_ledger = Ledger.find_by(name: "Close Out")
    client_ledger = Ledger.find_by(client_code: client_account.nepse_code)

    if settlement_by == 'client'
      bill.net_amount -= share_transaction.closeout_amount
      bill.closeout_charge += share_transaction.closeout_amount
      bill.save!
      description = "Shortage Sales adjustment (#{@closeout_quantity}*#{company_symbol}@#{share_rate}) Transaction number (#{share_transaction.contract_no}) of #{client_name}"
      voucher = Voucher.create!(date: settlement_date)
      voucher.desc = description
      process_accounts(closeout_ledger, voucher, false, share_transaction.closeout_amount, description, cost_center_id, settlement_date)
      process_accounts(client_ledger, voucher, true, share_transaction.closeout_amount, description, cost_center_id, settlement_date)
      voucher.complete!
      voucher.save!
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
