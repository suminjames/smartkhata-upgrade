class Reports::Excelsheet::ShareTransactionsReport < Reports::Excelsheet
  TABLE_HEADER = ["SN.", "Transaction Date", "Transaction No.", "Company", "Bill No.", "Quantity in", "Quantity out", "Market Rate", "Amount", "Commission"]

  def initialize(share_transactions, params, current_tenant)
    super(share_transactions, params, current_tenant)
    if params
      @client_account = ClientAccount.find_by(id: @params[:by_client_id]) if @params[:by_client_id].present?
      @isin_info = IsinInfo.find_by(id: @params[:by_isin_id]) if @params[:by_isin_id].present?
    end

    generate_excelsheet if data_present? && params_valid?
  end

  def data_present?
    # returns true if atleast one share transaction present
    data_present_or_set_error(@share_transactions, "Atleast one transaction is needed for exporting!")
  end

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
    headings, @file_name = case
    when @client_account && @isin_info
      [["Client-Company Report", "of \"#{@client_account.name.strip}\" for \"#{@isin_info.company.strip}\""],
      "ClientCompany_ShareTransactionReport_#{@client_account.id}_#{@isin_info.id}_#{@date}"]
    when @client_account
      [["Client Wise Report", "\"#{@client_account.name.strip}\""],
      "ClientWise_ShareTransactionReport_#{@client_account.id}_#{@date}"]
    when @isin_info
      [["Company Wise Report", "\"#{@isin_info.company.strip}\""],
      "CompanyWise_ShareTransactionReport_#{@isin_info.id}_#{@date}"]
    else # full report
      sub_heading = "All transactions"
      sub_heading << " of" if @params && [:by_date, :by_date_from, :by_date_to].any? {|x| @params[x].present?}
      [["Share Inventory Report", sub_heading],
      "ShareTransactionReport_#{@date}"]
    end
    add_document_headings(*headings)
  end

  def add_document_headings(heading, sub_heading)
    # Adds rows with document headings.
    add_document_headings_base(heading, sub_heading) {
      # if date queries present
      if @params && [:by_date, :by_date_from, :by_date_to].any? {|x| @params[x].present? }
        date_info = ""
        add_date_info = lambda {
          date_info.prepend "Transaction " if @client_account || @isin_info
          add_header_row(date_info, :info)
        }
        if @params[:by_date].present?
          date_info = "Date: #{@params[:by_date]}"
          add_date_info.call
        elsif [:by_date_from, :by_date_to].any? {|x| @params[x].present?}
          date_from = @params[:by_date_from].present? ? @params[:by_date_from] : '*'
          date_to = @params[:by_date_to].present? ? @params[:by_date_to] : '*'
          date_info = "Date Range: #{date_from} to #{date_to}"
          add_date_info.call
        end
        add_blank_row
      end
    }
  end

  def populate_data_rows
    # inserts the actual data rows through iteration.
    normal_style_row = [@styles[:normal_center]].push(*[@styles[:normal_style]]*2).insert(2, @styles[:int_format_left]).insert(3, @styles[:wrap]).push(*[@styles[:float_format]]*5)
    striped_style_row = [@styles[:striped_center]].push(*[@styles[:striped_style]]*2).insert(2, @styles[:int_format_left_striped]).insert(3, @styles[:wrap_striped]).push(*[@styles[:float_format_striped]]*5)
    @share_transactions.each_with_index do |st, index|
      # normal_style_row, striped_style_row = normal_style_row_default, striped_style_row_default
      sn = index + 1
      date = ad_to_bs_string(st.date)
      contract_num = st.contract_no
      company = st.isin_info.name_and_code
      if st.bill.present?
        bill_num = st.bill.full_bill_number
        normal_style_row[4] = @styles[:normal_style]
        striped_style_row[4] = @styles[:striped_style]
      else
        bill_num = 'N/A'
        normal_style_row[4] = @styles[:normal_style_muted]
        striped_style_row[4] = @styles[:striped_style_muted]
      end
      q_in = st.buying? ? st.quantity.to_f : ''
      q_out = st.selling? ? st.quantity.to_f : ''
      m_rate = st.isin_info.last_price.to_f
      share_amt = st.share_amount.to_f
      comm_amt = st.commission_amount.to_f
      row_style = index.even? ? normal_style_row : striped_style_row
      @sheet.add_row [sn, date, contract_num, company, bill_num, q_in, q_out, m_rate, share_amt, comm_amt],
                     style: row_style
    end
    add_total_row
  end

  def add_total_row
    columns_to_sum = [5, 6, 8, 9]
    alphabets = ('A'..'Z').to_a
    first_data_row = @doc_header_row_count+2
    last_data_row = first_data_row + @share_transactions.count - 1

    totalled_cells = []
    columns_to_sum.each do |col|
      totalled_cells << "=SUM(#{alphabets[col]}#{first_data_row}:#{alphabets[col]}#{last_data_row})"
    end
    @sheet.add_row totalled_cells.insert(0, 'Total').insert(1, *['']*4).insert(7, ''), style: [@styles[:total_keyword]].push(*[@styles[:total_values_float]]*9)
    @sheet.merge_cells("A#{last_data_row+1}:#{alphabets[columns_to_sum.min-1]}#{last_data_row+1}")
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
      @sheet.column_info.fourth.width = @isin_info.company.strip.length if @isin_info
    end
    # sheet.column_widths 6, nil, nil, nil
  end
end
