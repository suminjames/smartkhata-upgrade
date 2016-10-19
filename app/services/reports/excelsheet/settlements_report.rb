class Reports::Excelsheet::SettlementsReport < Reports::Excelsheet
  TABLE_HEADER = ["SN.", "Name", "Amount", "Bank", "Cheque Number", "Date", "Description", "Type"]

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
    settlement_type = case @settlement_type
    when 'payment', 'receipt'
      @settlement_type.capitalize
    else
      'Payment/Receipt'
    end
    headings = ["#{settlement_type} Report"]
    @file_name = "#{settlement_type.sub('/', '')}Report"
    if @client_account
      headings << "\"#{@client_account.name.strip}\""
      @file_name << "_#{@client_account.id}"
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
    normal_style_row = [@styles[:normal_center]].push(*[@styles[:wrap]]*6).insert(2, @styles[:float_format])
    striped_style_row = [@styles[:striped_center]].push(*[@styles[:wrap_striped]]*6).insert(2, @styles[:float_format_striped])
    # debugger
    row_index = 0
    @settlements.each_with_index do |s, index|
      sn = index + 1
      cheque_numbers, bank_names = s.formatted_cheque_numbers_and_bank_names(strip: false)
                                    .values_at(:cheque_numbers, :bank_names)
                                    .map{|d| d.split '<br>'}

      # shift: pops the first element. Empty string just in case..
      cheque_num = cheque_numbers.shift || ''
      bank_name = bank_names.shift || ''
      settlement_type = s.receipt? ? 'receipt' : 'payment'

      row_style = row_index.even? ? normal_style_row : striped_style_row
      @sheet.add_row [sn, s.name, s.amount, bank_name, cheque_num, s.date_bs, s.description, settlement_type], style: row_style
      row_index += 1

      # Add additional bank names and cheque numbers as distinct rows
      bank_names.each_with_index do |bank_name, sub_index|
        cheque_num = cheque_numbers[sub_index] || ''

        row_style = row_index.even? ? normal_style_row : striped_style_row
        @sheet.add_row (['']*6).insert(3, *[bank_name, cheque_num]), style: row_style
        row_index += 1
      end
    end
  end

  def set_column_widths
    # Sets fixed widths for a few required columns
    # Fixed width for first column which may be elongated by document headers
    # @sheet.column_info.first.width = 5

    # problems with auto width
    @sheet.column_widths 6, nil, nil, 25, 18, nil, 55
  end
end
