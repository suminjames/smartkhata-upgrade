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
    @settlements.each_with_index do |s, index|
      sn = index + 1
      # copy+pasted from view (_list)
      cheque_number = nil
      bank_name = nil
      if s.voucher.cheque_entries.present?
        s.voucher.cheque_entries.uniq.each do |cheque|
          if s.has_single_cheque? && cheque.client_account_id == s.client_account_id || !s.has_single_cheque?
            cheque_number = cheque.cheque_number
            bank_name = cheque.receipt? ? cheque.additional_bank.name : cheque.bank_account.bank_name
          end
        end
      end
      # 'N/A' for non_bank payment/receipt which don't have cheque_entry associated
      cheque_number ||= 'N/A'
      bank_name ||= 'N/A'

      settlement_type = s.receipt? ? 'receipt' : 'payment'

      row_style = index.even? ? normal_style_row : striped_style_row
      @sheet.add_row [sn, s.name, s.amount, bank_name, cheque_number, s.date_bs, s.description, settlement_type], style: row_style
    end
  end

  def set_column_widths
    # Sets fixed widths for a few required columns
    # Fixed width for first column which may be elongated by document headers
    # @sheet.column_info.first.width = 5

    # problems with auto width
    @sheet.column_widths 6, nil, nil, 25, 18
  end
end
