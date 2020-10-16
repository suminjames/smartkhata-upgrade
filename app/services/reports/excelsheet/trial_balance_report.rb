class Reports::Excelsheet::TrialBalanceReport < Reports::Excelsheet
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  TABLE_HEADER = ["Name", "Opening Balance Dr", "Opening Balance Cr", "Net Debit", "Net Credit", "Closing Balance Dr", "Closing Balance Cr"].freeze

  def initialize(balance_report, params, current_tenant)
    super(balance_report, params, current_tenant)
    generate_excelsheet if data_present?
  end

  def data_present?
    data_present_or_set_error(@balance_report, "No Data To export!")
  end

  def additional_styles(style_helpers)
    # the hook for injecting additional styles: should return a hash
    total_distinct = style_helpers[:total].merge(style_helpers[:bg_grey])

    {
      total_distinct: total_distinct,
      total_values_distinct: total_distinct.merge(style_helpers[:float]).deep_merge(style_helpers[:right]),
      table_sub_header: {sz: 14}.merge(style_helpers[:normal])
    }
  end

  def prepare_document
    # Adds document headings and sets the filename, before the real data table is inserted.
    add_document_headings("Trial Balance Report")
    @file_name = "TrialBalanceReport_#{@date}"
  end

  def add_document_headings(heading)
    # Adds rows with document headings.
    add_document_headings_base(heading) do
      # if date queries present
      if @params && @params[:search_by] == "date" && @params[:search_term].present?
        date_info = "As on date: #{@params[:search_term]}"

        add_header_row(date_info, :info)
        add_blank_row
      end
    end
  end

  def populate_data_rows
    # inserts the actual data rows through iteration.
    normal_style_row = [@styles[:wrap], *[@styles[:float_format_right]] * 6]
    striped_style_row = [@styles[:wrap_striped], *[@styles[:float_format_right_striped]] * 6]

    # initialize grand total values
    gr_total_blnc_cr = gr_total_blnc_dr = gr_total_net_credit = gr_total_net_debit = gr_total_closing_blnc_cr = gr_total_closing_blnc_dr = 0
    @balance_report.each do |group, ledgers|
      # sub content header row
      @sheet.add_row [group, *[''] * 6], style: @styles[:table_sub_header], height: 30
      @sheet.merge_cells "#{@sheet.rows.last.cells.first.r}:#{@sheet.rows.last.cells.last.r}" # r:alphanumeric cell reference

      # initialize total values
      total_blnc_cr = total_blnc_dr = total_net_credit = total_net_debit = total_closing_blnc_cr = total_closing_blnc_dr = 0

      ledgers.each_with_index do |ledger, index|
        name = ledger[:name]
        ledger = LedgerBalance.new(ledger.except(:name, 'lname'))

        blnc_dr = ledger.opening_balance > 1 ? ledger.opening_balance.round(2) : ''
        blnc_cr = ledger.opening_balance.negative? ? ledger.opening_balance.abs.round(2) : ''
        net_debit = ledger.dr_amount.round(2)
        net_credit = ledger.cr_amount.round(2)
        closing_blnc_dr = ledger.closing_balance.positive? ? ledger.closing_balance.round(2) : ''
        closing_blnc_cr = ledger.closing_balance.negative? ? ledger.closing_balance.abs.round(2) : ''

        row_style = index.even? ? striped_style_row : normal_style_row
        @sheet.add_row [name, blnc_dr, blnc_cr, net_debit, net_credit, closing_blnc_dr, closing_blnc_cr],
                       style: row_style

        # increment the total values
        total_blnc_cr += blnc_cr.to_f
        total_blnc_dr += blnc_dr.to_f
        total_net_debit += net_debit
        total_net_credit += net_credit
        total_closing_blnc_cr += closing_blnc_cr.to_f
        total_closing_blnc_dr += closing_blnc_dr.to_f
      end

      # sub content total row
      @sheet.add_row ['Total', total_blnc_dr, total_blnc_cr, total_net_debit, total_net_credit, total_closing_blnc_dr, total_closing_blnc_cr],
                     style: [@styles[:total_distinct], *[@styles[:total_values_distinct]] * 6]

      # increment the grand total values
      gr_total_blnc_cr += total_blnc_cr
      gr_total_blnc_dr += total_blnc_dr
      gr_total_net_debit += total_net_debit
      gr_total_net_credit += total_net_credit
      gr_total_closing_blnc_cr += total_closing_blnc_cr
      gr_total_closing_blnc_dr += total_closing_blnc_dr
    end
    # grand total row
    @sheet.add_row ['Grand Total', gr_total_blnc_dr, gr_total_blnc_cr, gr_total_net_debit, gr_total_net_credit, gr_total_closing_blnc_dr, gr_total_closing_blnc_cr],
                   style: [@styles[:total_distinct], *[@styles[:total_values_distinct]] * 6]
  end

  def set_column_widths
    # Sets fixed widths for a few required columns

    # Fixed width for first column which may be elongated by document headers
    @sheet.column_info.first.width = 30
  end
end
