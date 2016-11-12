class Mandala::BillDetail < ActiveRecord::Base
  self.table_name = "bill_detail"

  def daily_transactions
    Mandala::DailyTransaction.where(transaction_no: transaction_no, transaction_type: transaction_type)
  end
  def daily_transaction
    # it is supposed that daily transaction should be single for a bill detail
    if self.daily_transactions.size != 1
      raise NotImplementedError
    end

    daily_transactions.last
  end
end