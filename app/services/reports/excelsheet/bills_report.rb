class Reports::Excelsheet::BillsReport < Reports::Excelsheet
  # include ActionView::Helpers::NumberHelper
  # include ApplicationHelper

  # TABLE_HEADER = ["S.N.", "Bill No.", "Date (BS)", "Client", "Phone", "Type", "Status", "Companies Transacted", "Net Bill Amount"]

  def initialize(bills, params, current_tenant)
    super(bills, params, current_tenant)

    if params
      # the params contains "" strings so present? is checked
      @client_account = ClientAccount.find_by(id: @params[:by_client_id]) if @params[:by_client_id].present?
      @bill_type = @params[:by_bill_type] if @params[:by_bill_type].present?
      @bill_status = @params[:by_bill_status] if @params[:by_bill_status].present?
      @bill_number = @params[:by_bill_number] if @params[:by_bill_number].present?
      @selected_date = @params[:by_date] if @params[:by_date].present?
    end
    @column_count = get_column_count
    @last_column = @column_count - 1
    generate_excelsheet
  end

  def prepare_document
    # Adds document headings and sets the filename, before the real data table is inserted.
    headings = ["Bills Report"]
    @file_name = "BillsReport"

    if @bill_number
      headings << "Bill number: \"#{@bill_number}\""
      @file_name << "_#{@bill_number}"
    end
    if @client_account
      headings << "\"#{@client_account.name.strip}\""
      @file_name << "_client#{@client_account.id}"
    end
    if @bill_type
      headings << "of bill type \"#{@bill_type}\""
      @file_name << "_#{@bill_type}"
    end
    if @bill_status
      headings << "with \"#{@bill_status}\" status"
      @file_name << "_#{@bill_status}"
    end

    add_document_headings(headings)
    @file_name << "_#{@date}"
  end

  def get_header
    _header = if @selected_date && @bill_type
                ["S.N.", "Bill No.", "Client", "Phone", "Status", "Companies Transacted", "Net Bill Amount"]
              elsif @selected_date
                ["S.N.", "Bill No.", "Client", "Phone", "Type", "Status", "Companies Transacted", "Net Bill Amount"]
              elsif @bill_type
                ["S.N.", "Bill No.", "Date (BS)", "Client", "Phone", "Status", "Companies Transacted", "Net Bill Amount"]
              else
                ["S.N.", "Bill No.", "Date (BS)", "Client", "Phone", "Type", "Status", "Companies Transacted", "Net Bill Amount"]
              end
    _header
  end

  def populate_table_header
    _header = get_header
    # Adds table header row
    @sheet.add_row _header, style: @styles[:table_header]
  end

  def get_column_count
    get_header.count
  end

  def add_document_headings(headings)
    # Adds rows with document headings.
    sub_heading_present = !!(@bill_number || @client_account)
    add_document_headings_base(*headings, sub_heading_present: sub_heading_present, additional_infos_come_after_custom_block: false) do
      # if date queries present
      if @params && %i[by_date by_date_from by_date_to].any? { |x| @params[x].present? }
        date_info = ""
        add_date_info = lambda {
          add_header_row(date_info, :info)
        }
        if @params[:by_date].present?
          date_info = "Date: #{@params[:by_date]}"
          add_date_info.call
        elsif %i[by_date_from by_date_to].any? { |x| @params[x].present? }
          date_from = @params[:by_date_from].presence || '*'
          date_to = @params[:by_date_to].presence || '*'
          date_info = "Date Range: #{date_from} to #{date_to}"
          add_date_info.call
        end
        # add_blank_row
      end
    end
  end

  def populate_data_rows
    if @selected_date && @bill_type
      normal_style_row = [@styles[:normal_center], @styles[:normal_style], @styles[:wrap], @styles[:wrap], @styles[:normal_style], @styles[:wrap], @styles[:float_format_right]]
      striped_style_row = [@styles[:striped_center], @styles[:striped_style], @styles[:wrap_striped], @styles[:wrap_striped], @styles[:striped_style], @styles[:wrap_striped], @styles[:float_format_right_striped]]
    elsif @selected_date
      normal_style_row = [@styles[:normal_center], @styles[:normal_style], @styles[:wrap], @styles[:wrap], *[@styles[:normal_style]] * 2, @styles[:wrap], @styles[:float_format_right]]
      striped_style_row = [@styles[:striped_center], @styles[:striped_style], @styles[:wrap_striped], @styles[:wrap_striped], *[@styles[:striped_style]] * 2, @styles[:wrap_striped], @styles[:float_format_right_striped]]
    elsif @bill_type
      normal_style_row = [@styles[:normal_center], *[@styles[:normal_style]] * 2, @styles[:wrap], @styles[:wrap], @styles[:normal_style], @styles[:wrap], @styles[:float_format_right]]
      striped_style_row = [@styles[:striped_center], *[@styles[:striped_style]] * 2, @styles[:wrap_striped], @styles[:wrap_striped], @styles[:striped_style], @styles[:wrap_striped], @styles[:float_format_right_striped]]
    else
      normal_style_row = [@styles[:normal_center], *[@styles[:normal_style]] * 2, @styles[:wrap], @styles[:wrap], *[@styles[:normal_style]] * 2, @styles[:wrap], @styles[:float_format_right]]
      striped_style_row = [@styles[:striped_center], *[@styles[:striped_style]] * 2, @styles[:wrap_striped], @styles[:wrap_striped], *[@styles[:striped_style]] * 2, @styles[:wrap_striped], @styles[:float_format_right_striped]]
    end

    # inserts the actual data rows through iteration.
    @bills.each_with_index do |b, index|
      sn = index + 1
      bill_num = b.formatted_bill_number
      date_bs = b.formatted_bill_dates["bs"][0..-4]
      client = b.formatted_client_name
      phone = b.formatted_client_all_phones
      type = b.formatted_type
      status = b.formatted_status
      companies = b.formatted_companies_list
      net_amt = b.net_amount

      row_style = index.even? ? striped_style_row : normal_style_row

      if @selected_date && @bill_type
        @sheet.add_row [sn, bill_num, client, phone, status, companies, net_amt],
                       style: row_style
      elsif @selected_date
        @sheet.add_row [sn, bill_num, client, phone, type, status, companies, net_amt],
                       style: row_style
      elsif @bill_type
        @sheet.add_row [sn, bill_num, date_bs, client, phone, status, companies, net_amt],
                       style: row_style
      else
        @sheet.add_row [sn, bill_num, date_bs, client, phone, type, status, companies, net_amt],
                       style: row_style
      end
    end
  end

  def set_column_widths
    # Sets fixed widths for a few required columns because client column will wrap and wont look good
    # @sheet.column_widths 6, nil, nil, nil, nil, nil,nil, nil, 30
    # client account
    @sheet.column_info.fourth.width = 25 if @client_account
    @sheet.column_info.first.width = 6
  end
end
