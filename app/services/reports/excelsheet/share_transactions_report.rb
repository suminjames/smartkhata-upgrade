class Reports::Excelsheet::ShareTransactionsReport < Reports::Excelsheet
  TABLE_HEADER = ["SN.", "Transaction Date", "Transaction No.", "Company", "Bill No.", "Quantity in", "Quantity out", "Market Rate", "Amount", "Commission"]

  def initialize(share_transactions, params)
    super()
    @share_transactions = share_transactions
    if params
      @params = params
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
    if @client_account && @isin_info
      add_document_headings("Client-Company Report", "of \"#{@client_account.name.strip}\" for \"#{@isin_info.company.strip}\"")
      @file_name = "ClientCompany_ShareTransactionReport_#{@client_account.id}_#{@isin_info.id}_#{@date}"
    elsif @client_account
      add_document_headings("Client Wise Report", "\"#{@client_account.name.strip}\"")
      @file_name = "ClientWise_ShareTransactionReport_#{@client_account.id}_#{@date}"
    elsif @isin_info
      add_document_headings("Company Wise Report", "\"#{@isin_info.company.strip}\"")
      @file_name = "CompanyWise_ShareTransactionReport_#{@isin_info.id}_#{@date}"
    else # full report
      sub_heading = "All transactions"
      sub_heading << " of" if @params && [:by_date, :by_date_from, :by_date_to].any? {|x| @params[x].present?}
      add_document_headings("Share Inventory Report", sub_heading)
      @file_name = "ShareTransactionReport_#{@date}"
    end
  end

  def add_document_headings(heading, sub_heading)
    # Adds rows with document headings.
    add_document_headings_base(heading, sub_heading) {
      # if date queries present
      if @params && [:by_date, :by_date_from, :by_date_to].any? {|x| @params[x].present? }
        date_info = ""
        add_date_info = lambda {
          date_info.prepend "Transaction " if @client_account || @isin_info
          add_header_row(date_info, :date)
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
    normal_style_row = ([@styles[:normal_style]]*4).insert(2, @styles[:int_format]).push(*[@styles[:float_format]]*5)
    striped_style_row = ([@styles[:striped_style]]*4).insert(2, @styles[:int_format_striped]).push(*[@styles[:float_format_striped]]*5)
    @share_transactions.each_with_index do |st, index|
      # normal_style_row, striped_style_row = normal_style_row_default, striped_style_row_default
      sn = index + 1
      date = ad_to_bs_string(st.date)
      contract_num = st.contract_no
      company = st.isin_info.company
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
      # comm_amt = arabic_number(st.commission_amount)
      comm_amt = st.commission_amount.to_f
      row_style = index.even? ? normal_style_row : striped_style_row
      @sheet.add_row [sn, date, contract_num, company, bill_num, q_in, q_out, m_rate, share_amt, comm_amt],
                     style: row_style
    end
  end

  def set_column_widths
    # Sets fixed widths for a few required columns
    # Fixed width for first column which may be elongated by document headers
    @sheet.column_info.first.width = 6

    # Autowidth not working very well for long company names in Company wise report
    @sheet.column_info.fourth.width = @isin_info.company.strip.length if @isin_info
    # sheet.column_widths 6, nil, nil, nil
  end
end
