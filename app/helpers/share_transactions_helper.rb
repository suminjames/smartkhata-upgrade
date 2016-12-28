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

  # used in securities_flow's view (html, xls, pdf) to get headings
  def report_headings_for_securities_flow(params, is_securities_balance_view)
    isin_info_id = params.dig(:filterrific, :by_isin_id)
    date_bs = params.dig(:filterrific, :by_date)
    date_from_bs = params.dig(:filterrific, :by_date_from)
    date_to_bs = params.dig(:filterrific, :by_date_to)
    report_headings = []
    if is_securities_balance_view
      report_headings << "Securities Balance"
    else
      report_headings << "Securities Inwards/Outwards Register"
    end
    if isin_info_id.present?
      report_headings << "Company: #{IsinInfo.find(isin_info_id).name_and_code}"
    end
    if date_from_bs.present? && date_to_bs.present?
      report_headings << "Transactions From: #{date_from_bs} BS TO  #{date_to_bs} BS"
    elsif date_bs.present?
      report_headings << "Transactions Dated: #{date_bs} BS"
    end
    report_headings
  end
end
