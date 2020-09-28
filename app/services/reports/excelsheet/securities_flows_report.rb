class Reports::Excelsheet::SecuritiesFlowsReport < Reports::Excelsheet
  TABLE_HEADER = ["SN.", "Company", "Quantity In", "Quantity Out", "Quantity Balance"].freeze

  include ShareTransactionsHelper

  def initialize(securities_flows, is_securities_balance_view, params, current_tenant)
    super(securities_flows, is_securities_balance_view, params, current_tenant)
    @table_header_conditional = if @is_securities_balance_view
                                  ["SN.", "Company", "Quantity Balance"]
                                else
                                  ["SN.", "Company", "Quantity In", "Quantity Out", "Quantity Balance"]
                                end
    # conditional column count
    @column_count = @table_header_conditional.count
    @last_column = @column_count - 1 # starting from 0

    generate_excelsheet
  end

  # Override base method to add condition
  def populate_table_header
    @sheet.add_row @table_header_conditional, style: @styles[:table_header]
  end

  def prepare_document
    # Adds document headings and returns the filename conditionally, before the real data table is inserted.
    @file_name = @is_securities_balance_view ? 'Securities_Balances' : 'Securities_Flow_Register'
    report_headings = report_headings_for_securities_flow(@params, @is_securities_balance_view)
    headings = []
    report_headings.each_with_index do |heading, index|
      if index.zero?
        headings[0] = heading
      else
        headings[1] = "#{headings[1]} #{heading}"
      end
    end
    headings[1] = '' if report_headings.size < 2

    add_document_headings(*headings)
  end

  def add_document_headings(heading, sub_heading)
    # Adds rows with document headings.
    add_document_headings_base(heading, sub_heading) do
      if @date_query_present
        date_info = "" # needed for lambda
        add_date_info = lambda {
          date_info.prepend "Transaction " if @client_account || @isin_info
          add_header_row(date_info, :info)
        }
        if @params[:by_date].present?
          date_info = "Date: #{@params[:by_date]}"
        else
          date_from = @params[:by_date_from].presence || '*'
          date_to = @params[:by_date_to].presence || '*'
          date_info = "Date Range: #{date_from} to #{date_to}"
        end
        add_date_info.call
        add_blank_row
      end
    end
  end

  def populate_data_rows
    # inserts the actual data rows through iteration.
    normal_style_row = [@styles[:normal_center], @styles[:normal_style], @styles[:int_format_left], *[@styles[:wrap]] * 2, *[@styles[:normal_style]] * 2, *[@styles[:int_with_commas]] * 5, @styles[:float_format]]
    striped_style_row = [@styles[:normal_center], @styles[:normal_style], @styles[:int_format_left], *[@styles[:wrap]] * 2, *[@styles[:normal_style]] * 2, *[@styles[:int_with_commas]] * 5, @styles[:float_format]]

    @securities_flows.each_with_index do |securities_flow, index|
      isin_info = IsinInfo.find(securities_flow["isin_info_id"])
      sn = index + 1
      isin_info = isin_info.name_and_code

      qty_in = securities_flow["quantity_in_sum"]
      qty_out = securities_flow["quantity_out_sum"]
      qty_balance = securities_flow["quantity_balance"]

      row_style = index.even? ? normal_style_row : striped_style_row
      conditional_row = if @is_securities_balance_view
                          [sn, isin_info, qty_balance]
                        else
                          [sn, isin_info, qty_in, qty_out, qty_balance]
                        end
      @sheet.add_row conditional_row, style: row_style
    end
  end

  def set_column_widths
    # Sets fixed widths for a few required columns
    # Fixed width for first column which may be elongated by document headers
    @sheet.column_info.first.width = 6
  end
end
