class Reports::Excelsheet::SeboReport < Reports::Excelsheet
  TABLE_HEADER = ["S.no", "Company Name", "Buying Trans", "Buying Qty", "Buying Amt", "Sebo Comm", "Comm Amt", "Nepse Comm", "TDS", "Amount to Nepse", "Selling Trans", "Selling Qty", "Selling Amt", "Comm Amt", "TDS", "Sebp Comm", "Nepse Comm", "Capital Gain", "Amt.From Nepse", "Total Trans", "Total Qty", "Total Amount"]

  include ShareTransactionsHelper

  def initialize(share_transactions, params)
    super
    if params
      @date_query_present = [:by_date, :by_date_from, :by_date_to].any? {|x| params[x].present?}
    end

    generate_excelsheet
  end

  def prepare_document
    # Adds document headings and sets the filename, before the real data table is inserted.
    add_document_headings("Sebo Report")
    @file_name = "SeboReport_#{@date}"
  end

  def add_document_headings(heading)
    # Adds rows with document headings.
    add_document_headings_base(heading) {
      if @date_query_present
        date_info = "" # needed for lambda
        add_date_info = lambda {
          add_header_row(date_info, :info)
        }
        if @params[:by_date].present?
          date_info = "Date: #{@params[:by_date]}"
        else
          date_from = @params[:by_date_from].present? ? @params[:by_date_from] : '*'
          date_to = @params[:by_date_to].present? ? @params[:by_date_to] : '*'
          date_info = "Date Range: #{date_from} to #{date_to}"
        end
        add_date_info.call
        add_blank_row
      end
    }
  end

  def populate_data_rows
    # inserts the actual data rows through iteration.
    row_style = [@styles[:normal_center], @styles[:wrap], *[@styles[:int_format_right]]*2, *[@styles[:float_format]]*6, *[@styles[:int_format_right]]*2, *[@styles[:float_format]]*7, *[@styles[:int_format_right]]*2, @styles[:int_format_right]]

    @share_transactions.each_with_index do |share_transaction, index|
      sn = index + 1
      company = share_transaction.isin_info.company
      buy_transaction_count = share_transaction["buy_transaction_count"]
      buy_quantity = share_transaction["buy_quantity"]
      buying_amount = share_transaction["buying_amount"]
      buy_sebo_comm = share_transaction["buy_sebo_comm"]
      buy_comm_amount = share_transaction["buy_comm_amount"]
      buy_nepse_comm = share_transaction["buy_nepse_comm"]
      buy_tds = share_transaction["buy_tds"]
      amount_to_nepse = share_transaction["amount_to_nepse"]
      selling_transaction_count = share_transaction["selling_transaction_count"]
      selling_quantity = share_transaction["selling_quantity"]
      selling_amount = share_transaction["selling_amount"]
      selling_comm_amount = share_transaction["selling_comm_amount"]
      selling_tds = share_transaction["selling_tds"]
      selling_sebo_comm = share_transaction["selling_sebo_comm"]
      selling_nepse_comm = share_transaction["selling_nepse_comm"]
      total_cgt = share_transaction["total_cgt"]
      amount_from_nepse = share_transaction["amount_from_nepse"]
      total_transaction_count = share_transaction["total_transaction_count"]
      total_quantity = share_transaction["total_quantity"]
      total_amount = share_transaction["total_amount"]

      # row_style = index.even? ? normal_style_row : striped_style_row
      row = [sn, company, buy_transaction_count, buy_quantity,buying_amount, buy_sebo_comm, buy_comm_amount, buy_nepse_comm, buy_tds, amount_to_nepse, selling_transaction_count, selling_quantity, selling_amount, selling_comm_amount, selling_tds, selling_sebo_comm, selling_nepse_comm, total_cgt, amount_from_nepse, total_transaction_count, total_quantity, total_amount]
      @sheet.add_row row, style: row_style
    end
  end

  def set_column_widths
    # Sets fixed widths for a few required columns
    # Fixed width for first column which may be elongated by document headers
    @sheet.column_info.first.width = 6
    @sheet.column_info.second.width = 25
  end
end
