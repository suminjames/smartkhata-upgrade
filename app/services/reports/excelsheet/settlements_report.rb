class Reports::Excelsheet::SettlementsReport < Reports::Excelsheet
  TABLE_HEADER = ["Name", "Amount", "Date", "Description", "Type"]

  def initialize(settlements, params, current_tenant)
    super(settlements, params, current_tenant)
    if params
      @client_account = ClientAccount.find_by(id: @params[:by_client_id]) if @params[:by_client_id].present?
      @settlement_type = @params[:by_settlement_type] if @params[:by_settlement_type].present?
    end

    # No conditions: presence check is done in the view itself + need to finish fast!
    generate_excelsheet
  end

  def prepare_document
    # Conditionally adds document headings and sets the filename
    headings = ["Payment/Receipt Report"]
    @file_name = "SettlementReport"
    if @client_account
      headings << "\"#{@client_account.name.strip}\""
      @file_name << "_#{@client_account.id}"
    end
    if @settlement_type
      headings << "Settlement Type: #{@settlement_type}"
      @file_name << "_#{@settlement_type}"
    end
    @file_name << "_#{@date}"
    add_document_headings(headings)
  end

  def add_document_headings(headings)
    headings << "" if headings.count == 1 # empty subheadings
    # Adds rows with document headings.
    add_document_headings_base(*headings) {
      # if date queries present
      if @params && [:by_date, :by_date_from, :by_date_to].any? {|x| @params[x].present? }
        date_info = ""
        add_date_info = lambda {
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
    normal_style_row = ([@styles[:wrap]]*4).insert(1, @styles[:float_format])
    striped_style_row = ([@styles[:wrap_striped]]*4).insert(1, @styles[:float_format_striped])
    @settlements.each_with_index do |s, index|
      settlement_type = s.receipt? ? 'receipt' : 'payment'
      row_style = index.even? ? normal_style_row : striped_style_row
      # debugger
      @sheet.add_row [s.name, s.amount, s.date_bs, s.description, settlement_type], style: row_style
    end
  end

  def set_column_widths
    # Sets fixed widths for a few required columns
    # Fixed width for first column which may be elongated by document headers
    @sheet.column_info.first.width = 30

    # sheet.column_widths 6, nil, nil, nil
  end
end
