class Reports::Pdf::ShareTransactionsReport < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper

  def initialize(share_transactions, params, current_tenant, print_in_letter_head)
    @share_transactions = share_transactions
    @current_tenant = current_tenant
    @print_in_letter_head = print_in_letter_head

    @date = ad_to_bs Date.today

    if params
      @params = params
      @client_account = ClientAccount.find_by(id: @params[:by_client_id]) if @params[:by_client_id].present?
      @isin_info = IsinInfo.find_by(id: @params[:by_isin_id]) if @params[:by_isin_id].present?
      @group_by_company = params[:group_by_company] == 'true'
      @transaction_type = params[:by_transaction_type]
    end

    if @print_in_letter_head
      top_margin = 38.mm
      bottom_margin = 11.mm
    else
      top_margin = 12
      bottom_margin = 18
    end

    @hide_company_column =  @group_by_company
    @hide_client_account_column = @client_account.present?

    super(top_margin: top_margin, right_margin: 38, bottom_margin: bottom_margin, left_margin: 18)

    draw
  end

  def self.file_name(params)
    if params
      @params = params
      @client_account = ClientAccount.find_by(id: @params[:by_client_id]) if @params[:by_client_id].present?
      @isin_info = IsinInfo.find_by(id: @params[:by_isin_id]) if @params[:by_isin_id].present?
    end
    if @client_account && @isin_info
      @file_name = "ClientCompany_ShareTransactionReport_#{@client_account.nepse_code}_#{@isin_info.isin}_"
    elsif @client_account
      @file_name = "ClientWise_ShareTransactionReport_#{@client_account.nepse_code}"
    elsif @isin_info
      @file_name = "CompanyWise_ShareTransactionReport_#{@isin_info.isin}"
    else # full report
      @file_name = "ShareTransactionReport_#{Date.today}"
    end
  end

  def draw
    font_size(9) do
      move_down(3)
      company_header unless @print_in_letter_head
      report_header
      share_transactions_list
      move_down(3)
      generate_page_number
    end
  end

  def page_width
    558
  end

  def page_height
    770
  end

  def col (unit)
    unit / 12.0 * page_width
  end

  def hr
    pad_bottom(3) do
      stroke_horizontal_rule
    end
  end

  def br
    text "\n"
  end

  def report_header
    # Adds document headings and returns the filename conditionally
    document_headings = ["Share Transactions details"]
    if @client_account && @isin_info
      document_headings.push("of \"#{@client_account.name_and_nepse_code}\" for \"#{@isin_info.company.strip}\"")
      @file_name = "ClientCompany_ShareTransactionReport_#{@client_account.id}_#{@isin_info.id}_#{@date}"
    elsif @client_account
      document_headings.push("of \"#{@client_account.name_and_nepse_code}\"")
      @file_name = "ClientWise_ShareTransactionReport_#{@client_account.id}_#{@date}"
    elsif @isin_info
      document_headings.push("for \"#{@isin_info.company.strip}\"")
      @file_name = "CompanyWise_ShareTransactionReport_#{@isin_info.id}_#{@date}"
    else # full report
      sub_heading = "All transactions"
      sub_heading << " of" if @params && [:by_date, :by_date_from, :by_date_to].any? {|x| @params[x].present?}
      document_headings.push("Share Inventory Report", sub_heading)
      @file_name = "ShareTransactionReport_#{@date}"
    end

    if @transaction_type.present?
      document_headings.push("Transaction Type: #{@transaction_type.titleize}")
    end

    if @params && [:by_date, :by_date_from, :by_date_to].any? {|x| @params[x].present? }
      date_info = ""
      date_info = date_info.prepend "Transaction " if @client_account || @isin_info
      if @params[:by_date].present?
        date_info += "Date: #{@params[:by_date]}"
        document_headings.push(date_info)
      elsif [:by_date_from, :by_date_to].any? {|x| @params[x].present?}
        date_from = @params[:by_date_from].present? ? @params[:by_date_from] : '*'
        date_to = @params[:by_date_to].present? ? @params[:by_date_to] : '*'
        date_info += "Date Range: #{date_from} to #{date_to}"
        document_headings.push(date_info)
      end
    end

    report_date = ad_to_bs Date.today
    document_headings.push("Report Date: #{report_date}")

    table_data  = []
    document_headings.each do |heading|
      table_data << [
          heading
      ]
    end
    table_width = page_width - 2
    table table_data do |t|
      t.row(0..1).font_style = :bold
      t.row(0..1).size = 9
      t.cell_style = {:border_width => 0, :padding => [2, 4, 2, 2]}
      t.column(0).style(:align => :center)
      t.column_widths = {0 => table_width}
    end
  end

  def share_transactions_list
    table_data = []
    th_data = ["SN.", "Date", "Transaction No.", "Company", "Client", "Bill No.", "Qty\nin", "Qty\nout", "Rate", "Amount", "Commission"]
    table_data << th_data
    total_q_in = 0
    total_q_out = 0
    total_share_amt = 0
    total_comm_amt = 0
    isin_balances = Hash.new(0)
    grouped_isin_total_rows = []
    @share_transactions.each_with_index do |st, index|
      sn = index + 1
      date = ad_to_bs_string(st.date)
      contract_num = st.contract_no
      company = st.isin_info.name_and_code
      client_name = st.client_account.name_and_nepse_code
      bill_num = st.bill.present? ? st.bill.full_bill_number : 'N/A'
      q_in = st.buying? ? st.quantity.to_i : ''
      q_in_str = st.buying? ? arabic_number_integer(q_in) : ''
      q_out = st.selling? ? st.quantity.to_i : ''
      q_out_str = st.selling? ? arabic_number_integer(q_out) : ''
      m_rate = strip_redundant_decimal_zeroes(st.share_rate.to_f)
      share_amt = strip_redundant_decimal_zeroes(st.share_amount.to_f)
      comm_amt = st.commission_amount.to_f

      total_q_in += q_in.to_i # to_i used to convert empty string value to 0
      total_q_out += q_out.to_i # to_i used to convert empty string value to 0
      total_share_amt += share_amt
      total_comm_amt += comm_amt

      table_data << [
          sn,
          date,
          contract_num,
          company,
          client_name,
          bill_num,
          q_in_str,
          q_out_str,
          arabic_number_integer(m_rate),
          arabic_number_integer(share_amt),
          arabic_number(comm_amt)
      ]

      if @group_by_company
        if st.buying?
          isin_balances[:total_in_sum] += st.quantity
          isin_balances[:balance_share_amount] += st.share_amount
        elsif st.selling?
          isin_balances[:total_out_sum] += st.quantity
          isin_balances[:balance_share_amount] -= st.share_amount
        end
      end

      # Logic for adding total row for groups of companies in the listing.
      break_group = false
      break_group = @group_by_company && ( (@share_transactions.size - 1) == index || st.isin_info_id != @share_transactions[index + 1].isin_info_id )
      if break_group
        isin_balances[:floorsheet_blnc_sum] = isin_balances[:total_in_sum] - isin_balances[:total_out_sum]
        grouped_isin_total_row = [
            {:content => "Company: #{st.isin_info.isin}\n(#{st.isin_info.company})", :colspan => grouped_isin_total_row_colspan},
            "Total",
            "Qty\nIn:\n#{isin_balances[:total_in_sum].to_i}",
            "Qty\nOut:\n#{isin_balances[:total_out_sum].to_i}",
            "Qty\nBlnc:\n#{isin_balances[:floorsheet_blnc_sum].to_i}",
            "Amount:\nBalance\n#{arabic_number(isin_balances[:balance_share_amount])}",
            ""
        ]
        table_data << grouped_isin_total_row
        # Track index of grouped isin total rows for custom formatting (later).
        grouped_isin_total_rows << (index + 2 + grouped_isin_total_rows.size)
        isin_balances = Hash.new(0)
      end
    end

    total_row_data = [
        '',
        '',
        '',
        '',
        '',
        'Grand Total',
        total_q_in,
        total_q_out,
        '',
        arabic_number(total_share_amt),
        arabic_number(total_comm_amt)
    ]
    table_data << total_row_data

    company_column_index = 3
    client_account_column_index = 4
    if @hide_company_column || @hide_client_account_column
      if @hide_company_column && @hide_client_account_column
        # Index of client_account columns shifts by 1 (to 0)
        client_account_column_index = 3
      end
      table_data.each_with_index do |table_row, index|
        unless grouped_isin_total_rows.include?(index)
          table_row.delete_at(company_column_index) if @hide_company_column
          table_row.delete_at(client_account_column_index) if @hide_client_account_column
        end
      end
    end

    table table_data do |t|
      t.header = true
      t.row(0).font_style = :bold
      t.row(0).size = 9
      t.column(0..6).style(:align => :center)
      t.column(5..-1).style(:align => :right)
      t.row(0).style(:align => :center)
      t.cell_style = {:border_width => 1, :padding => [2, 4, 2, 2]}
      t.column_widths = column_widths
      t.row(-1).size = 9
      t.row(-1).font_style = :bold
      grouped_isin_total_rows.each do |row_number|
        t.row(row_number).font_style = :bold_italic
      end
    end

  end

  def grouped_isin_total_row_colspan
    colspan = 5
    if @hide_company_column
      colspan -=  1
    end
    if @hide_client_account_column
      colspan -=  1
    end
    colspan
  end

  def column_widths
    table_width = page_width - 2

    col_width = {}
    col_width[:sn] = table_width * 0.7/12.0
    col_width[:date] = table_width * 1.2/12.0
    col_width[:transaction_no] = table_width * 1.8/12.0
    col_width[:company] = table_width * 1.1/12.0
    col_width[:client_account] = table_width * 1.1/12.0
    col_width[:bill_no] = table_width * 1.2/12.0
    col_width[:qty_in] = table_width * 0.7/12.0
    col_width[:qty_out] = table_width * 0.7/12.0
    col_width[:rate] = table_width * 0.8/12.0
    col_width[:amount] = table_width * 1.4/12.0
    col_width[:commission] = table_width * 1.3/12.0

    column_widths = {0 => col_width[:sn],
                     1 => col_width[:date],
                     2 => col_width[:transaction_no],
                     3 => col_width[:company],
                     4 => col_width[:client_account],
                     5 => col_width[:bill_no],
                     6 => col_width[:qty_in],
                     7 => col_width[:qty_out],
                     8 => col_width[:rate],
                     9 => col_width[:amount],
                     10 => col_width[:commission]
    }

    total_deleted_column_width = 0
    total_available_columns = 0

    # Readjust column_widths as needed.
    if @hide_company_column && @hide_client_account_column
      total_deleted_columns = 2
      total_deleted_column_width = col_width[:company] + col_width[:client_account]
      total_available_columns = column_widths.size - total_deleted_columns
      (3..8).each do |key|
        column_widths[key] = column_widths[key + total_deleted_columns]
      end
      column_widths.delete(9)
      column_widths.delete(10)
    elsif  @hide_company_column && !@hide_client_account_column
      total_deleted_columns = 1
      total_deleted_column_width = col_width[:company]
      total_available_columns = column_widths.size - total_deleted_columns
      (3..9).each do |key|
        column_widths[key] = column_widths[key + total_deleted_columns]
      end
      column_widths.delete(10)
    elsif  !@hide_company_column && @hide_client_account_column
      total_deleted_columns = 1
      total_deleted_column_width = col_width[:client_account]
      total_available_columns = column_widths.size - total_deleted_columns
      (4..9).each do |key|
        column_widths[key] = column_widths[key + total_deleted_columns]
      end
      column_widths.delete(10)
    else
      # default column_widths
      # do nothing
    end

    if @hide_company_column || @hide_client_account_column
      additional_width_per_column = total_deleted_column_width / total_available_columns
      # Distribute (deleted) additional width to remaining columns.
      column_widths.each do |key, value|
        column_widths[key] += additional_width_per_column
      end
    end

    column_widths
  end


  def generate_page_number
    string = "page <page> of <total>"
    options = { :at => [bounds.right - 150, 0],
                :width => 150,
                :align => :right,
                :start_count_at => 1
    }
    number_pages string, options
  end

  def company_header
    row_cursor = cursor
    bounding_box([0, row_cursor], :width => col(9)) do
      text "<b>#{@current_tenant.full_name}</b>", :inline_format => true, :size => 11
      text "#{@current_tenant.address}"
      text "Phone: #{@current_tenant.phone_number}"
      text "Fax: #{@current_tenant.fax_number}"
      text "PAN: #{@current_tenant.pan_number}"
    end
    hr
  end

end
