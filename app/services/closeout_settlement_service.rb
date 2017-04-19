# service to settle closeout
class CloseoutSettlementService
  attr_reader :share_transaction, :error, :settlement_by

  SETTLEMENT_TYPES = %w(client broker)

  def initialize( transaction, settlement_by, params={})
    @share_transaction = transaction
    @error = nil
    @settlement_by = settlement_by
  end

  def process
    return unless validate?
    ActiveRecord::Base.transaction do
      process_sales_closeout if share_transaction.selling?
    end
  end


  def validate?
  #   in case of sales, settlement by allowed is only client and broker self
    unless SETTLEMENT_TYPES.include?(settlement_by)
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
end
