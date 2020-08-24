class Reports::Excelsheet::LedgersReport < Reports::Excelsheet
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  # Blank column to merge later.
  TABLE_HEADER = ["Date", "Date AD", "Particulars", "Voucher", "Bill", "Cheque", "Pay/Receipt No", "Transaction Amount", "", "Balance"]

  def initialize(ledger, params, current_tenant, ledger_query)
    super(ledger, params, current_tenant)

    # Needed for merging later, as transaction amount will be having two columns
    @transxn_amt_first_col = TABLE_HEADER.index("Transaction Amount")
    @ledger_query = ledger_query
    @branch_id = ledger_query.branch_id
    @fy_code = ledger_query.fy_code
    @opening_balance = ledger.opening_balance(@fy_code, @branch_id)
    generate_excelsheet if data_present?
  end

  def data_present?
    # Checks for the presence of ledger and particulars
    # data_present_or_set_error(@particulars, "Atleast one particular is needed for exporting!") &&
    data_present_or_set_error(@ledger, "No ledger specified!")
  end

  def prepare_document
    # Adds document headings and returns the filename, before the real data table is inserted.

    closing_balance = @ledger.closing_balance(@fy_code, @branch_id)
    opening_closing_blnc = \
      "Opening Balance:  #{number_to_currency(@opening_balance.abs)} #{@opening_balance >= 0 ? 'Dr' : 'Cr'}"\
      " | "\
      "Closing Balance: #{number_to_currency(closing_balance.abs)} #{closing_balance + margin_of_error_amount >= 0 ? 'Dr' : 'Cr'}"
    client = (@params && @params[:for_client] == "1") ? "Client" : ""

    add_document_headings("#{client} Ledger Report", "\"#{@ledger.name.strip.titleize}\"", opening_closing_blnc)
    @file_name = "#{client}LedgerReport_#{@fy_code}_#{@branch_id}_#{@ledger.id}_#{@date}"
  end

  def add_document_headings(heading, sub_heading, opening_closing_blnc)
    # Adds rows with document headings.
    add_document_headings_base(heading, sub_heading, opening_closing_blnc) {
      # if date queries present
      if @params && @params[:search_by] == "date_range"  && @params[:search_term].present? && [:date_from, :date_to].any? {|x| @params[:search_term][x].present? }
        date_from = @params[:search_term][:date_from].present? ? @params[:search_term][:date_from] : '*'
        date_to = @params[:search_term][:date_to].present? ? @params[:search_term][:date_to] : '*'
        date_info = "within Date Range: #{date_from} to #{date_to}"

        add_header_row(date_info, :info)
        add_blank_row
      end
    }
  end

  def populate_table_header
    # Override base method to add condition
    TABLE_HEADER[5] = "Settlement ID" if @ledger.name == "Nepse Purchase"
    @sheet.add_row TABLE_HEADER, style: @styles[:table_header]
    @sheet.add_row (['']*(@column_count-2)).insert(@transxn_amt_first_col, *['dr', 'cr']), style: @styles[:table_header]

    # Merge the vertical cells through range
    # table header rows to merge
    i, j = @doc_header_row_count+1, @doc_header_row_count+2
    # skip the two "transaction amount" columns in the middle
    # due to the cr and dr
    cell_ranges_to_merge = ('A'..'G').inject([]){|k,v| k.push("#{v}#{i}:#{v}#{j}")}.push "J#{i}:J#{j}" # static columns mention
    cell_ranges_to_merge.each { |range| @sheet.merge_cells(range) }
    # Finally merge the two horizontal cells
    @sheet.merge_cells("H#{i}:I#{i}") # static column mention
  end

  def particulars_query
    @ledger_query.ledger_with_particulars(true)[0]
  end

  def particulars_ids
    @ledger_query.particular_ids(true)
  end

  def populate_data_rows
    # inserts the actual data rows through iteration.
    # normal_style_row = @styles[:normal_style]
    normal_style_row = ([@styles[:normal_style]]*(@column_count-4)).insert(1, @styles[:wrap]).insert(@transxn_amt_first_col, *[@styles[:float_format_right]]*2).push(@styles[:normal_right])
    striped_style_row = ([@styles[:striped_style]]*(@column_count-4)).insert(1, @styles[:wrap_striped]).insert(@transxn_amt_first_col, *[@styles[:float_format_right_striped]]*2).push(@styles[:striped_right])

    query = particulars_query
    running_total = @ledger_query.opening_balance_calculated

    # why not find each
    # because it wont allow to order
    particulars_ids.in_groups_of(1000).each do |photo_ids|
      query.where(id: photo_ids).each_with_index do |p, index|
        # normal_style_row, striped_style_row = normal_style_row_default, striped_style_row_default
        date = p.date_bs
        date_ad = p.transaction_date.to_s
        desc = p.get_description
        voucher = "#{p.voucher.voucher_code} #{p.voucher.fy_code}-#{p.voucher.voucher_number.to_s.rjust(5,'0')}"

        bills = ""
        p.bills.each_with_index do |bill, bill_index|
          if bill.client_account_id == @ledger.client_account_id || @ledger.client_account_id.nil?
            bills << "#{bill.fy_code}-#{bill.bill_number.to_s.rjust(5,'0')}"
            bills << ", "
          end
        end
        bills.chomp! ", "
        cheque_entries = p.cheque_entries.map{|cheque_entry| cheque_entry.cheque_number.to_s}.join(", ")
        cheque_entries << " (#{p.nepse_chalan.nepse_settlement_id})" if p.nepse_chalan.present?
        settlements = p.settlements.map{ |settlement| "#{settlement.id}" }.join(", ")
        transaction_amt = p.amount
        transaction_amt_dr = p.dr? ? transaction_amt : ''
        transaction_amt_cr = p.cr? ? transaction_amt : ''

        running_total += (p.dr? ? transaction_amt : transaction_amt * -1)
        balance = number_to_currency(running_total.abs).to_s
        running_total + margin_of_error_amount < 0 ? balance << " cr" : balance << " dr"

        row_style = index.even? ? normal_style_row : striped_style_row
        @sheet.add_row [date, date_ad, desc, voucher, bills, cheque_entries, settlements, transaction_amt_dr, transaction_amt_cr, balance], style: row_style
      end
    end
  end

  def set_column_widths
    # Sets fixed widths for a few required columns
    # Fixed width for first column which may be elongated by document headers
    # @sheet.column_info.first.width = 12

    # Fixed width for Particulars
    # @sheet.column_info.second.width = 40

    # Make 'cr' & 'dr' of the same width.
    @sheet.column_widths 12, 12, 40, nil, nil, nil, nil, 15, 15
  end

  # def data_valid?
    #   if @particulars.any?{|p| p.try(:ledger) != @ledger}
    #     # if one or more particulars doesn't belong to the relevant ledger.
    #     @error = "Inconsistent or invalid particulars provided!"
    #     false
    #   else
    #     true
    #   end
  # end

end
