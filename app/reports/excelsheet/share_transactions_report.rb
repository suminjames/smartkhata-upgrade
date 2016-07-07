Class Excelsheet::ShareTransactionsReport
  include CustomDateModule

  TABLE_HEADER = ["Date", "Contract No", "Company", "Quantity in", "Quantity out", "Rate", "Market Rate", "Amount"]

  def initialize(params)
    @params = params
    @date = ad_to_bs Date.today
    generate_excelsheet
  end

  def generate_excelsheet
    package = Axlsx::Package.new
    workbook = package.workbook
    workbook.add_worksheet(name: "Sheet 1") do |sheet|
      workbook.styles do |s|
        @styles = add_styles(s)

        setup_with_document_headers

        sheet.add_row TABLE_HEADER, style: @styles[:table_header]

        populate_data_rows if @share_transactions

        # Fixed width for date regardless of top level headers
        sheet.column_info.first.width = 12
      end
    end
    file_path = "#{Rails.root}/tmp/#{@file_name}.xlsx"
    package.serialize file_path

    file_path
  end

  def add_styles(obj)
    table_header = obj.add_style alignment: {horizontal: :center}, b: true, sz: 12, bg_color: "3c8dbc", fg_color: "FF", border: Axlsx::STYLE_THIN_BORDER
    doc_header = obj.add_style sz: 20, fg_color: "3c8dbc"
    doc_sub_header = obj.add_style sz: 14

    border = {border: {style: :thin, color: "3c8dbc"}}
    bg = {bg_color: "f9f9f9"}
    striped = border.merge bg

    normal_style = obj.add_style border
    striped_style = obj.add_style striped
    date_format = obj.add_style({format_code: 'YYYY-MM-DD'}.merge border)
    date_format_striped = obj.add_style({format_code: 'YYYY-MM-DD'}.merge striped)
    int_format = obj.add_style({num_fmt: 1}.merge border)
    int_format_striped = obj.add_style({num_fmt: 1}.merge striped)

    # [table_header, doc_header, doc_sub_header, border, bg, striped, normal_style, striped_style, date_format, date_format_striped, int_format, int_format_striped]
    local_variables-[:_].inject(Hash.new){|k,v| k[v] = eval(v.to_s); k}
  end

  def setup_with_document_headers
    # search by client
    if @params[:search_by] == 'client' && client_account = ClientAccount.find_by(id: @params[:search_term])
      add_document_headers.call("Client Wise Report", "\"#{client_account.name.strip}\"")
      @share_transactions = ShareTransaction.not_cancelled.where(client_account_id: client_account.id).includes(:isin_info).order(:isin_info_id)
      @file_name = "ClientWise_ShareTransactionReport_#{client_account.id}_#{@date}"
    # search by company
    elsif @params[:search_by] == 'company' && isin = IsinInfo.find_by(id: @params[:search_term])
      add_document_headers.call("Company Wise Report", "\"#{isin.company.strip}\"")
      @share_transactions = ShareTransaction.not_cancelled.where(isin_info_id: isin.id).includes(:isin_info).order(:isin_info_id)
      @file_name = "CompanyWise_ShareTransactionReport_#{isin.id}_#{@date}"
    else # full report
      add_document_headers.call("Share Inventory Report", "All transactions")
      @share_transactions = ShareTransaction.not_cancelled.includes(:isin_info).order(:isin_info_id)
      @file_name = "ShareTransactionReport_#{@date}"
    end
  end

  def add_document_headers(title, sub_title)
    sheet.add_row [title], style: @styles[:doc_header]
    sheet.add_row [""]
    sheet.add_row [sub_title], style: @styles[:doc_sub_header]
    sheet.add_row ["Date: #{@date}"]
    sheet.add_row [""]
  end

  def populate_data_rows
    isin_price_list = get_latest_isin_price_list
    @share_transactions.each_with_index do |st, row|
      q_in = st.buying? ? st.quantity : ''
      q_out = st.selling? ? st.quantity : ''
      m_rate = isin_price_list[st.isin_info.isin]
      if row.even?
        style_arr = [@styles[:date_format], @styles[:int_format]].push *[@styles[normal_style]]*6
      else
        style_arr = [@styles[date_format_striped], @styles[int_format_striped]].push *[@styles[striped_style]]*6
      end
      sheet.add_row [ad_to_bs_string(st.date), st.contract_no, st.isin_info.isin, q_in, q_out, st.share_rate, m_rate, st.share_amount], style: style_arr
    end
  end
end