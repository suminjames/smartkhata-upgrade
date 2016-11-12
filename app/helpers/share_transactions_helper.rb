module ShareTransactionsHelper

  #
  # Sort transaction_messages first by bill_id and then by isin_info_id
  # Logic excerpted from: http://stackoverflow.com/questions/4309723/ruby-sort-by-multiple-values
  #
  def sort_by_bill_and_isin_info(share_transactions)
    share_transactions.sort do  |a, b|
      [a.bill_id, a.isin_info_id] <=> [b.bill_id, b.isin_info_id]
    end
  end
end
