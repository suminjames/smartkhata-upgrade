class Reports::Excelsheet::ShareTransactionsReport < Reports::Excelsheet
  TABLE_HEADER = ["SN.", "Transaction Date", "Transaction No.", "Company", "Client", "Bill No.", "Broker", "Quantity in", "Quantity out", "Rate", " Current Market Rate", "Amount", "Commission"].freeze
  include ApplicationHelper

  def initialize(share_transactions, params, current_tenant)
    super(share_transactions, params, current_tenant)
    if params
      @client_account = ClientAccount.find_by(id: @params[:by_client_id]) if @params[:by_client_id].present?
      @isin_info = IsinInfo.find_by(id: @params[:by_isin_id]) if @params[:by_isin_id].present?
      @date_query_present = %i[by_date by_date_from by_date_to].any? { |x| @params[x].present?}
      @group_by_company = params[:group_by_company] == 'true'
      @transaction_type = params[:by_transaction_type]
    end

    @hide_company_column = @group_by_company
    @hide_client_account_column = @client_account.present?

    generate_excelsheet if params_valid?
  end

  # Not needed anymore as this check is run in the view.
  # def data_present?
  #   # returns true if atleast one share transaction present
  #   data_present_or_set_error(@share_transactions, "Atleast one transaction is needed for exporting!")
  # end

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
    report = 'ShareTransactionReport'
    heading = "Share Transactions details"
    headings, @file_name = if @client_account && @isin_info
                             [
                               [
                                 heading, "of \"#{@client_account.name_and_nepse_code}\" for \"#{@isin_info.company.strip}\""
                               ],
                               "ClientCompany_#{report}_#{@client_account.id}_#{@isin_info.id}_#{@date}"
                             ]
                           elsif @client_account
                             [
                               [
                                 heading, "\"#{@client_account.name_and_nepse_code}\""
                               ],
                               "ClientWise_#{report}_#{@client_account.id}_#{@date}"
                             ]
                           elsif @isin_info
                             [
                               [
                                 heading, "\"#{@isin_info.company.strip}\""
                               ],
                               "CompanyWise_#{report}_#{@isin_info.id}_#{@date}"
                             ]
                           else # full report
                             sub_heading = "All transactions"
                             sub_heading << " of" if @date_query_present
                             [
                               [
                                 heading, sub_heading
                               ],
                               "#{report}_#{@date}"
                             ]
                           end
    add_document_headings(*headings)
  end

  def add_document_headings(heading, sub_heading)
    # Adds rows with document headings.
    add_document_headings_base(heading, sub_heading) do
      if @date_query_present
        date_info = "" # needed for lambda
        add_date_info = lambda {
          date_info.prepend "Transaction " if @client_account || @isin_info
          add_header_row(date_info, :info)
        }
        if @params[:by_date].present?
          date_info = "Date: #{@params[:by_date]}"
        else
          date_from = @params[:by_date_from].presence || '*'
          date_to = @params[:by_date_to].presence || '*'
          date_info = "Date Range: #{date_from} to #{date_to}"
        end
        add_date_info.call
        add_blank_row
      end
      add_header_row("Transaction Type: #{@transaction_type.titleize}", :info) if @transaction_type.present?
    end
  end

  def populate_data_rows
    # inserts the actual data rows through iteration.
    normal_style_row = [@styles[:normal_center], @styles[:normal_style], @styles[:int_format], *[@styles[:wrap]] * 2, *[@styles[:normal_style]] * 2, *[@styles[:int_with_commas]] * 5, @styles[:float_format]]
    striped_style_row = [@styles[:striped_center], @styles[:striped_style], @styles[:int_format_left_striped], *[@styles[:wrap_striped]] * 2, *[@styles[:striped_style]] * 2, *[@styles[:int_with_commas_striped]] * 5, @styles[:float_format_striped]]

    isin_total_style_row = [@styles[:total_values]] * 12
    isin_balances = Hash.new(0)

    @actual_row_index_count = 0
    @share_transactions.each_with_index do |st, index|
      # normal_style_row, striped_style_row = normal_style_row_default, striped_style_row_default
      sn = index + 1
      date = ad_to_bs_string(st.date)
      contract_num = st.contract_no
      company = st.isin_info.name_and_code
      client = st.client_account&.name_and_nepse_code
      if st.bill.present?
        bill_num = st.bill.full_bill_number
        normal_style_row[5] = @styles[:normal_style]
        striped_style_row[5] = @styles[:striped_style]
      else
        bill_num = 'N/A'
        normal_style_row[5] = @styles[:normal_style_muted]
        striped_style_row[5] = @styles[:striped_style_muted]
      end
      broker = st.selling? ? st.buyer : st.seller
      q_in = st.buying? ? st.quantity.to_f : ''
      q_out = st.selling? ? st.quantity.to_f : ''
      rate = st.share_rate
      m_rate = st.isin_info.last_price.to_f
      share_amt = st.share_amount.to_f
      comm_amt = st.commission_amount.to_f
      row_style = index.even? ? normal_style_row : striped_style_row
      row_style = @actual_row_index_count.even? ? normal_style_row : striped_style_row
      row = [sn, date, contract_num, company, client, bill_num, broker, q_in, q_out, rate, m_rate, share_amt, comm_amt]
      added_row = @sheet.add_row conditional_row(row), style: conditional_row_style(row_style)
      # force the contract number to be string
      added_row.cells[2].type = :string

      @actual_row_index_count += 1

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
      break_group = @group_by_company && ((@share_transactions.size - 1) == index || st.isin_info_id != @share_transactions[index + 1].isin_info_id)
      next unless break_group

      isin_balances[:balance_sum] = isin_balances[:total_in_sum] - isin_balances[:total_out_sum]
      grouped_isin_total_row = [
        "Company: #{st.isin_info.isin}\n(#{st.isin_info.company})",
        "",
        "",
        "",
        "",
        "",
        "Total",
        "Qty In:#{isin_balances[:total_in_sum].to_i}",
        "Qty Out:#{isin_balances[:total_out_sum].to_i}",
        "Qty Balance:\n#{isin_balances[:balance_sum].to_i}",
        "",
        "Amount Balance: #{arabic_number(isin_balances[:balance_share_amount])}",
        ""
      ]
      row_style = isin_total_style_row
      grouped_isin_total_row = conditional_row(grouped_isin_total_row)
      @sheet.add_row grouped_isin_total_row, style: row_style
      first_data_row = @doc_header_row_count + 2
      latest_data_row = first_data_row + @actual_row_index_count - 1
      alphabets = ('A'..'Z').to_a
      @sheet.merge_cells("A#{latest_data_row + 1}:#{alphabets[grouped_isin_total_row.find_index("Total") - 1]}#{latest_data_row + 1}")
      @actual_row_index_count += 1
      isin_balances = Hash.new(0)
    end
    add_total_row
  end

  def conditional_row(row)
    row = row.dup
    if @hide_company_column && @hide_client_account_column
      row.delete_at(3)
      row.delete_at(3)
    elsif @hide_company_column && !@hide_client_account_column
      row.delete_at(3)
    elsif !@hide_company_column && @hide_client_account_column
      row.delete_at(4)
    end
    row
  end

  def conditional_row_style(row_style)
    return row_style if row_style.class != Array

    row_style = row_style.dup
    if @hide_company_column && @hide_client_account_column
      row_style.delete_at(3)
      row_style.delete_at(3)
    elsif @hide_company_column && !@hide_client_account_column
      row_style.delete_at(3)
    elsif !@hide_company_column && @hide_client_account_column
      row_style.delete_at(4)
    end
    row_style
  end

  def conditional_columns_to_sum
    columns_to_sum = [7, 8, 11, 12]
    if @hide_company_column && @hide_client_account_column
      columns_to_sum.map! { |e| e - 2}
    elsif @hide_company_column && !@hide_client_account_column
      columns_to_sum.map! { |e| e - 1}
    elsif !@hide_company_column && @hide_client_account_column
      columns_to_sum.map! { |e| e - 1}
    end
    columns_to_sum
  end

  def add_total_row
    columns_to_sum = conditional_columns_to_sum
    alphabets = ('A'..'Z').to_a
    first_data_row = @doc_header_row_count + 2
    last_data_row = first_data_row + @actual_row_index_count - 1

    totalled_cells = []
    columns_to_sum.each do |col|
      totalled_cells << "=SUM(#{alphabets[col]}#{first_data_row}:#{alphabets[col]}#{last_data_row})"
    end
    total_row = totalled_cells.insert(0, 'Grand Total').insert(1, *[''] * 6).insert(9, *[''] * 2)
    @sheet.add_row conditional_row(total_row), conditional_row_style(style: [@styles[:total_keyword]].push(*[@styles[:total_values_float]] * 12))
    @sheet.merge_cells("A#{last_data_row + 1}:#{alphabets[columns_to_sum.min - 1]}#{last_data_row + 1}")
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
      @sheet.column_info.fourth.width = @isin_info.name_and_code.strip.length
    end
    # sheet.column_widths 6, nil, nil, nil
  end

  # Method override
  def populate_table_header
    # Adds table header row
    @sheet.add_row conditional_row(TABLE_HEADER), style: conditional_row_style(@styles[:table_header])
  end
end
