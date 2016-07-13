class Reports::Excelsheet::LedgersReport < Reports::Excelsheet
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  TABLE_HEADER = ["Date", "Particulars", "Voucher", "Bill", "Cheque", "Pay/Receipt No", "Transaction Amount", "Balance"]

  def initialize(ledger, particulars, params)
    super()
    @ledger = ledger
    @particulars = particulars
    @params = params

    generate_excelsheet if data_present? #&& data_valid?
    # check params?
  end

  def data_present?
    # Checks for the presence of ledger and particulars
    data_present_or_set_error(@particulars, "Atleast one particular is needed for exporting!") &&
    data_present_or_set_error(@ledger, "No ledger specified!")
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

  def prepare_document
    # Adds document headings and returns the filename, before the real data table is inserted.
    add_document_headings("Ledger", "\"#{@ledger.name.strip.titleize}\"")
    @file_name = "Ledger_#{@ledger.id}_#{@date}"
  end

  def add_document_headings(heading, sub_heading)
    # Adds rows with document headings.
    add_document_headings_base(heading, sub_heading) {
      # if date queries present
      if @params && @params[:search_by] == "date_range"  && @params[:search_term].present? && [:date_from, :date_to].any? {|x| @params[:search_term][x].present? }
        date_from = @params[:search_term][:date_from].present? ? @params[:search_term][:date_from] : '*'
        date_to = @params[:search_term][:date_to].present? ? @params[:search_term][:date_to] : '*'
        date_info = "within Date Range: #{date_from} to #{date_to}"

        add_header_row(date_info, :date)
        add_blank_row
      end
    }
  end

  def populate_table_header
    # Override base method to add condition
    TABLE_HEADER[4] = "Settlement ID" if @ledger.name == "Nepse Purchase"
    @sheet.add_row TABLE_HEADER, style: @styles[:table_header]
  end

  def populate_data_rows
    # inserts the actual data rows through iteration.
    # normal_style_row = ([@styles[:normal_style]]*4).insert(2, @styles[:int_format]).push(*[@styles[:float_format]]*5)
    # striped_style_row = ([@styles[:striped_style]]*4).insert(2, @styles[:int_format_striped]).push(*[@styles[:float_format_striped]]*5)
    normal_style_row = @styles[:normal_style]
    striped_style_row = @styles[:striped_style]
    @particulars.each_with_index do |p, index|
      # normal_style_row, striped_style_row = normal_style_row_default, striped_style_row_default
      date = p.date_bs
      desc = p.get_description
      voucher = "#{p.voucher.voucher_code} #{p.voucher.fy_code}-#{p.voucher.voucher_number}"

      bills = ""
      if p.bills.size > 0
        bill_count = p.bills.count
          p.bills.each_with_index do |bill, bill_index|
            if bill.client_account_id == @ledger.client_account_id
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

      transaction_amt = number_to_currency(p.amount).to_s
      p.cr? ? transaction_amt << " cr" : transaction_amt << " dr"

      balance = number_to_currency(p.running_blnc.abs).to_s
      p.running_blnc + margin_of_error_amount < 0 ? balance << " cr" : balance << " dr"

      row_style = index.even? ? normal_style_row : striped_style_row
      @sheet.add_row [date, desc, voucher, bills, cheque_entries, settlements, transaction_amt, balance],
                     style: row_style
    end
  end

  def set_column_widths
    # Sets fixed widths for a few required columns
    # Fixed width for first column which may be elongated by document headers
    @sheet.column_info.first.width = 12

    # Fixed width for Particulars
    @sheet.column_info.second.width = 40
  end
end
