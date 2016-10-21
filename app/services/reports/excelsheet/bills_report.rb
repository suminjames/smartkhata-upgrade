class Reports::Excelsheet::BillsReport < Reports::Excelsheet
  # include ActionView::Helpers::NumberHelper
  # include ApplicationHelper

  TABLE_HEADER = ["S.N.", "Bill No.", "Date (BS)", "Client", "Type", "Status", "Companies Transacted", "Net Bill Amount"]

  def initialize(bills, params, current_tenant)
    super(bills, params, current_tenant)

    if params
      @client_account = ClientAccount.find_by(id: @params[:by_client_id]) if @params[:by_client_id].present?
      @bill_type = @params[:by_bill_type] if @params[:by_bill_type].present?
      @bill_status = @params[:by_bill_status] if @params[:by_bill_status].present?
      @bill_number = @params[:by_bill_number] if @params[:by_bill_number].present?
    end

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

  def add_document_headings(headings)
    # Adds rows with document headings.
    sub_heading_present = !!(@bill_number || @client_account)
    add_document_headings_base(*headings, sub_heading_present: sub_heading_present, additional_infos_come_after_custom_block: false) {
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
    normal_style_row = ([@styles[:normal_center], *[@styles[:normal_style]]*2, @styles[:wrap], *[@styles[:normal_style]]*2, @styles[:wrap], @styles[:float_format_right]])
    striped_style_row = ([@styles[:striped_center], *[@styles[:striped_style]]*2, @styles[:wrap_striped], *[@styles[:striped_style]]*2, @styles[:wrap_striped], @styles[:float_format_right_striped]])

    # inserts the actual data rows through iteration.
    @bills.each_with_index do |b, index|
      sn = index + 1
      bill_num = b.formatted_bill_number
      date_bs = b.formatted_bill_dates["bs"][0..-4]
      client = b.formatted_client_name
      type = b.formatted_type
      status = b.formatted_status
      companies = b.formatted_companies_list
      net_amt = b.net_amount

      row_style = index.even? ? striped_style_row : normal_style_row
      @sheet.add_row [sn, bill_num, date_bs, client, type, status, companies, net_amt],
                       style: row_style
    end
  end

  def set_column_widths
    # Sets fixed widths for a few required columns

    # sn, companies transacted
    @sheet.column_widths 6, nil, nil, nil, nil, nil, 40

    # client account
    @sheet.column_info.fourth.width = 25 if @client_account
  end

end
