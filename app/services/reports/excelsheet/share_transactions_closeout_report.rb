class Reports::Excelsheet::ShareTransactionsCloseoutReport < Reports::Excelsheet
  TABLE_HEADER = ["SN.", "Transaction Date", "Transaction No.", "Company", "Client", "Broker", "Quantity in", "Quantity out", "Close Out Quantity", "Rate", "Closeout Amount"].freeze

  def initialize(share_transactions, params, current_tenant)
    super(share_transactions, params, current_tenant)
    if params
      @client_account = ClientAccount.find_by(id: @params[:by_client_id]) if @params[:by_client_id].present?
      @isin_info = IsinInfo.find_by(id: @params[:by_isin_id]) if @params[:by_isin_id].present?
      @date_query_present = %i[by_date by_date_from by_date_to].any? { |x| @params[x].present?}
      @group_by_company = params[:group_by_company] == 'true'
    end

    generate_excelsheet if params_valid?
  end

  # Not needed anymore as this check is run in the view.
  # def data_present?
  #   # returns true if atleast one share transaction present
  #   data_present_or_set_error(@share_transactions, "Atleast one transaction is needed for exporting!")
  # end

  def params_valid?
    # Currently checks only for validity of client/company id.
    # Returns true for nil param
    if @params && (@params[:by_client_id].present? && !@client_account || @params[:by_isin_id].present? && !@isin_info)
      @error = "Specified client or company account not present!"
      false
    # add other checks here!
    else
      true
    end
  end

  def prepare_document
    # Adds document headings and returns the filename conditionally, before the real data table is inserted.
    report = 'ShareTransactionReport'
    headings, @file_name = if @client_account && @isin_info
                             [["Client-Company Closeout Report", "of \"#{@client_account.name.strip}\" for \"#{@isin_info.company.strip}\""],
                              "ClientCompany_#{report}_#{@client_account.id}_#{@isin_info.id}_#{@date}"]
                           elsif @client_account
                             [["Client Wise Closeout Report", "\"#{@client_account.name.strip}\""],
                              "ClientWise_#{report}_#{@client_account.id}_#{@date}"]
                           elsif @isin_info
                             [["Company Wise Closeout Report", "\"#{@isin_info.company.strip}\""],
                              "CompanyWise_#{report}_#{@isin_info.id}_#{@date}"]
                           else # full report
                             sub_heading = "All Transactions"
                             sub_heading << " of" if @date_query_present
                             [["Share Transactions Closeout Report", sub_heading],
                              "#{report}_#{@date}"]
                           end
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
    normal_style_row = [@styles[:normal_center], @styles[:normal_style], @styles[:int_format_left], *[@styles[:wrap]] * 2, @styles[:normal_style], *[@styles[:int_with_commas]] * 4, @styles[:float_format]]

    @actual_row_index_count = 0
    @share_transactions.each_with_index do |st, index|
      # normal_style_row, striped_style_row = normal_style_row_default, striped_style_row_default
      sn = index + 1
      date = ad_to_bs_string(st.date)
      contract_num = st.contract_no
      company = st.isin_info.name_and_code
      client = st.client_account.name_and_nepse_code
      broker = st.selling? ? st.buyer : st.seller
      q_in = st.buying? ? st.raw_quantity.to_f : ''
      q_out = st.selling? ? st.raw_quantity.to_f : ''
      closeout_qty = st.raw_quantity - st.quantity
      rate = st.share_rate
      closeout_amt = st.closeout_amount.to_f
      row_style =  normal_style_row
      @sheet.add_row [sn, date, contract_num, company, client, broker, q_in, q_out, closeout_qty, rate, closeout_amt], style: row_style
      @actual_row_index_count += 1
    end
  end

  def set_column_widths
    # Sets fixed widths for a few required columns
    # Fixed width for first column which may be elongated by document headers
    @sheet.column_info.first.width = 6
    if @client_account && !@isin_info
      # Client wise report as well
      @sheet.column_info.fourth.width = 40
    elsif @isin_info
      # Autowidth not working very well for long company names in Company wise report
      @sheet.column_info.fourth.width = @isin_info.name_and_code.strip.length
    end
    # sheet.column_widths 6, nil, nil, nil
  end
end
