class Reports::Excelsheet::ShareTransactionsReport < Reports::Excelsheet
  TABLE_HEADER = ["SN.", "Transaction Date", "Transaction No.", "Company", "Bill No.", "Quantity in", "Quantity out", "Market Rate", "Amount", "Commission"]

  def initialize(share_transactions, params)
    @share_transactions = share_transactions
    @date = ad_to_bs Date.today
    # @errors = []
    @doc_header_row_count = 5 # Default, without date queries
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

  def generate_excelsheet
    # generates the full report & sets file path for it.
    package = Axlsx::Package.new
    workbook = package.workbook
    workbook.add_worksheet(name: "Sheet 1") do |sheet|
      @sheet = sheet
      workbook.styles do |s|
        define_styles(s)
        prepare_document

        populate_table_header
        populate_data_rows

        set_column_widths
        merge_header_cells
      end
    end
    @path = "#{Rails.root}/tmp/#{@file_name}.xlsx"
    package.serialize @path
  end

  def define_styles(obj)
    # Defines and adds necessary styles to the workbook styles object & sets their hash to @styles variable.

    # center_bordered = {alignment: {horizontal: :center}, border: {style: :thin, color: "000"}}
    border = {border: {style: :thin, color: "3c8dbc"}}
    border_right = {border: {style: :thin, color: "d2d6de", edges: [:right]}} #color: "808080"
    striped_bg = {bg_color: "f9f9f9"}
    white_bg = {bg_color: "FF"}
    center = {alignment: {horizontal: :center}}
    center_clear = center.merge white_bg
    muted = {fg_color: "808080"}
    striped = border.merge striped_bg
    # center_bordered = center.merge border_right

    doc_header_style = {sz: 20, fg_color: "3c8dbc"}.merge center_clear
    doc_sub_header_style = {sz: 14}.merge center_clear

    @styles = {
      table_header: obj.add_style({b: true, sz: 12, bg_color: "3c8dbc", fg_color: "FF", border: Axlsx::STYLE_THIN_BORDER}.merge center),

      # date: [obj.add_style(center_clear)].insert(9, obj.add_style(center_clear.merge border_right)),
      date: obj.add_style(center_clear.merge border_right),
      blank: obj.add_style(white_bg.merge border_right),
      doc_header: obj.add_style(doc_header_style.merge border_right),
      doc_sub_header: obj.add_style(doc_sub_header_style.merge border_right),

      normal_style: obj.add_style(border),
      striped_style: obj.add_style(striped),
      # date_format: obj.add_style({format_code: 'YYYY-MM-DD'}.merge border)
      # date_format_striped: obj.add_style({format_code: 'YYYY-MM-DD'}.merge striped)
      int_format: obj.add_style({num_fmt: 1}.merge border),
      int_format_striped: obj.add_style({num_fmt: 1}.merge striped),
      float_format: obj.add_style({num_fmt: 4}.merge border),
      float_format_striped: obj.add_style({num_fmt: 4}.merge striped),
      normal_style_muted: obj.add_style(border.merge muted),
      striped_style_muted: obj.add_style(striped.merge muted)
    }

    # (local_variables-[:obj]).inject(Hash.new){|k,v| k[v] = eval(v.to_s); k}
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

  def add_document_headings(title, sub_title)
    # Adds rows with document headings.
    blank_row = lambda {@sheet.add_row [''].insert(9, ''), style: @styles[:blank]}
    @sheet.add_row [title].insert(9, ''), style: @styles[:doc_header]
    blank_row.call
    @sheet.add_row [sub_title].insert(9, ''), style: @styles[:doc_sub_header]
    # if date queries present
    if @params && [:by_date, :by_date_from, :by_date_to].any? {|x| @params[x].present? }
      date_info = ""
      add_date_info = lambda {
        date_info.prepend "Transaction " if @client_account || @isin_info
        @sheet.add_row [date_info].insert(9, ''), style: @styles[:date]
      }
      if @params[:by_date].present?
        date_info = "Date: #{@params[:by_date]}"
        date_info << " &" if [:by_date_from, :by_date_to].any? {|x| @params[x].present?}
        add_date_info.call
        @doc_header_row_count += 1
      end
      if [:by_date_from, :by_date_to].any? {|x| @params[x].present?}
        date_from = @params[:by_date_from].present? ? @params[:by_date_from] : '*'
        date_to = @params[:by_date_to].present? ? @params[:by_date_to] : '*'
        date_info = "Date Range: #{date_from} to #{date_to}"
        add_date_info.call
        @doc_header_row_count += 1
      end
      blank_row.call
      @doc_header_row_count += 1
    end

    @sheet.add_row ["Report Date: #{@date}"].insert(9, ''), style: @styles[:date]
    blank_row.call
  end

  def populate_table_header
    # Adds table header row
    @sheet.add_row TABLE_HEADER, style: @styles[:table_header]
  end

  def populate_data_rows
    # inserts the actual data rows through iteration.
    if @share_transactions
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
  end

  def set_column_widths
    # Sets fixed widths for a few required columns
    # Fixed width for first column which may be elongated by document headers
    @sheet.column_info.first.width = 6

    # Autowidth not working very well for long company names in Company wise report
    @sheet.column_info.fourth.width = @isin_info.company.strip.length if @isin_info
    # sheet.column_widths 6, nil, nil, nil
  end

  def merge_header_cells
    # Merges cells in each header row for clarity
    cell_ranges_to_merge = []

    # 10 columns(A..J)
    1.upto(@doc_header_row_count){|n| cell_ranges_to_merge << "A#{n}:J#{n}"}
    cell_ranges_to_merge.each do |range|
      @sheet.merge_cells(range)
    end
  end
end
