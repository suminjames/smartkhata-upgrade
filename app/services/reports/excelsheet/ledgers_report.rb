class Reports::Excelsheet::LedgersReport < Reports::Excelsheet
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  # Blank column to merge later.
  TABLE_HEADER = ["Date", "Particulars", "Voucher", "Bill", "Cheque", "Pay/Receipt No", "Transaction Amount", "", "Balance"]

  def initialize(ledger, particulars, params, current_tenant)
    super(ledger, particulars, params, current_tenant)

    # Needed for merging later, as transaction amount will be having two columns
    @transxn_amt_first_col = TABLE_HEADER.index("Transaction Amount")

    generate_excelsheet if data_present?
  end

  def data_present?
    # Checks for the presence of ledger and particulars
    # data_present_or_set_error(@particulars, "Atleast one particular is needed for exporting!") &&
    data_present_or_set_error(@ledger, "No ledger specified!")
  end

  def prepare_document
    # Adds document headings and returns the filename, before the real data table is inserted.
    opening_closing_blnc = \
      "Opening Balance:  #{number_to_currency(@ledger.opening_balance.abs)} #{@ledger.opening_balance >= 0 ? 'Dr' : 'Cr'}"\
      " | "\
      "Closing Balance: #{number_to_currency(@ledger.closing_balance.abs)} #{@ledger.closing_balance + margin_of_error_amount >= 0 ? 'Dr' : 'Cr'}"
    client = (@params && @params[:for_client] == "1") ? "Client" : ""

    add_document_headings("#{client} Ledger Report", "\"#{@ledger.name.strip.titleize}\"", opening_closing_blnc)
    @file_name = "#{client}LedgerReport_#{@ledger.id}_#{@date}"
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
    TABLE_HEADER[4] = "Settlement ID" if @ledger.name == "Nepse Purchase"
    @sheet.add_row TABLE_HEADER, style: @styles[:table_header]
    @sheet.add_row (['']*(@column_count-2)).insert(@transxn_amt_first_col, *['cr', 'dr']), style: @styles[:table_header]

    # Merge the vertical cells through range
    # table header rows to merge
    i, j = @doc_header_row_count+1, @doc_header_row_count+2
    # skip the two "transaction amount" columns in the middle
    cell_ranges_to_merge = ('A'..'F').inject([]){|k,v| k.push("#{v}#{i}:#{v}#{j}")}.push "I#{i}:I#{j}" # static columns mention
    cell_ranges_to_merge.each { |range| @sheet.merge_cells(range) }

    # Finally merge the two horizontal cells
    # @sheet.merge_cells("#{letters[@transxn_amt_first_col]}#{i}:#{@transxn_amt_first_col+1}#{i}")
    @sheet.merge_cells("G#{i}:H#{i}") # static column mention
  end

  def populate_data_rows
    # inserts the actual data rows through iteration.
    # normal_style_row = @styles[:normal_style]
    normal_style_row = ([@styles[:normal_style]]*(@column_count-4)).insert(1, @styles[:wrap]).insert(@transxn_amt_first_col, *[@styles[:float_format_right]]*2).push(@styles[:normal_right])
    striped_style_row = ([@styles[:striped_style]]*(@column_count-4)).insert(1, @styles[:wrap_striped]).insert(@transxn_amt_first_col, *[@styles[:float_format_right_striped]]*2).push(@styles[:striped_right])
    @particulars.each_with_index do |p, index|
      # normal_style_row, striped_style_row = normal_style_row_default, striped_style_row_default
      date = p.date_bs
      desc = p.get_description
      voucher = "#{p.voucher.voucher_code} #{p.voucher.fy_code}-#{p.voucher.voucher_number}"

      bills = ""
      if p.bills.size > 0
        bill_count = p.bills.count
          p.bills.each_with_index do |bill, bill_index|
            if bill.client_account_id == @ledger.client_account_id || @ledger.client_account_id.nil?
             bills << "#{bill.fy_code}-#{bill.bill_number}"
             bills << ", " unless bill_index == bill_count-1
            end
          end
      end

      cheque_entries = ""
      if p.cheque_entries.size > 0
        cheque_count = p.cheque_entries.size
        p.cheque_entries.each_with_index do |cheque, cheque_index|
          cheque_entries << cheque.cheque_number.to_s
          cheque_entries << ", " unless cheque_index == cheque_count-1
        end
      end
      if p.nepse_chalan.present?
        cheque_entries << " (#{p.nepse_chalan.nepse_settlement_id})"
      end

      settlements = ""
      if p.voucher.settlements.size > 0
        settlement_count = p.voucher.settlements.size
        p.voucher.settlements.each_with_index do |settlement, settlement_index|
          settlements << settlement.id.to_s
          settlements << ", " unless settlement_index == settlement_count-1
        end
      end

      transaction_amt = p.amount
      transaction_amt_cr = p.cr? ? transaction_amt : ''
      transaction_amt_dr = p.dr? ? transaction_amt : ''

      balance = number_to_currency(p.running_total.abs).to_s
      p.running_total + margin_of_error_amount < 0 ? balance << " cr" : balance << " dr"

      row_style = index.even? ? normal_style_row : striped_style_row
      @sheet.add_row [date, desc, voucher, bills, cheque_entries, settlements, transaction_amt_cr, transaction_amt_dr, balance],
                     style: row_style
    end
  end

  def set_column_widths
    # Sets fixed widths for a few required columns
    # Fixed width for first column which may be elongated by document headers
    # @sheet.column_info.first.width = 12

    # Fixed width for Particulars
    # @sheet.column_info.second.width = 40

    # Make 'cr' & 'dr' of the same width.
    @sheet.column_widths 12, 40, nil, nil, nil, nil, 15, 15
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
