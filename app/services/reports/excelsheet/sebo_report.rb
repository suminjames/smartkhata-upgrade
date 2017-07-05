class Reports::Excelsheet::SeboReport < Reports::Excelsheet
  TABLE_HEADER = ["SN.", "Company", "Buying Trans", "Buying Qty", "Buying Amt", "Sebo Comm"]

  include ShareTransactionsHelper

  def initialize(share_transactions)
    super(share_transactions)
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
          date_info.prepend "Transaction " if @client_account || @isin_info
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
    row_style = [@styles[:normal_center], @styles[:wrap], @styles[:int_format_right], *[@styles[:float_format]]*3]

    @share_transactions.each_with_index do |share_transaction, index|
      sn = index + 1
      company = share_transaction.isin_info.company
      buy_transaction_count = share_transaction["buy_transaction_count"]
      buying_amount = share_transaction["buying_amount"]
      buy_sebo_comm = share_transaction["buy_sebo_comm"]

      # row_style = index.even? ? normal_style_row : striped_style_row
      row = [sn, company, buy_transaction_count, buying_amount, buy_sebo_comm]
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
