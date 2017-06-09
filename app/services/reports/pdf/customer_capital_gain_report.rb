class Reports::Pdf::CustomerCapitalGainReport < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper
  include ShareTransactionsHelper

  def initialize(share_transactions, current_tenant, opts = {})
    opts = {
        :fiscal_year => get_fy_code(Date.today),
        :print_in_letter_head => false
    }.merge(opts)
    @share_transactions = share_transactions
    @current_tenant = current_tenant

    @print_in_letter_head = opts[:print_in_letter_head]
    @fiscal_year = opts[:fiscal_year]

    if @print_in_letter_head
      top_margin = 38.mm
      bottom_margin = 11.mm
    else
      top_margin = 12
      bottom_margin = 18
    end

    super(top_margin: top_margin, right_margin: 38, bottom_margin: bottom_margin, left_margin: 18)

    draw
  end

  def draw
    font_size(9) do
      move_down(3)
      company_header unless @print_in_letter_head
      report_header
      client_info
      move_down 3
      share_transactions_section
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

  def share_transactions_section
    row_cursor = cursor
    bounding_box([0, row_cursor], :width => col(12)) do
      data = []
      th_data = ["Bill No.", "Company", "Transaction No.", "Transaction\nDate", "Capital\nGain Tax"]
      data << th_data

      total_capital_gain = 0
      previous_row_bill = nil

      @share_transactions = sort_by_bill_and_isin_info(@share_transactions)
      @share_transactions.each do |share_transaction|
        current_bill = share_transaction.bill

        if current_bill.blank? || current_bill != previous_row_bill
          if current_bill.blank?
            bill_row_span = 1
          else
            previous_row_bill = current_bill
            bill_row_span = @share_transactions.select{|e| e.bill_id == current_bill.id}.size
          end
          row_data = [
              {
                  :content => share_transaction.bill.present? ? share_transaction.bill.full_bill_number : 'N/A',
                  :rowspan => bill_row_span
              },
              share_transaction.isin_info.name_and_code,
              share_transaction.contract_no,
              "#{ad_to_bs(share_transaction.date)} BS" ,
              arabic_number(share_transaction.cgt)
          ]
        else
          row_data = [
              share_transaction.isin_info.name_and_code,
              share_transaction.contract_no,
              "#{ad_to_bs(share_transaction.date)} BS" ,
              arabic_number(share_transaction.cgt)
          ]
        end

        total_capital_gain += share_transaction.cgt
        data << row_data
      end
      last_row_data = ["", "", "", "Total", arabic_number(total_capital_gain)]
      data << last_row_data

      table_width = page_width - 2
      column_widths = {0 => table_width * 1.5/12.0, 1 => table_width * 5.5/12.0, 2 => table_width * 2/12.0, 3 => table_width * 1.5/12.0, 4 => table_width * 1.5/12.0}
      table data do |t|
        t.header = true
        t.row(0).font_style = :bold
        t.row(-1).font_style = :bold_italic
        t.cell_style = {:border_width => 0.1, :padding => [2, 2, 2, 2]}
        t.column(2).style(:align => :center)
        t.column(3).style(:align => :right)
        t.column(-1).style(:align => :right)
        t.row(-1).style(:align => :right)
        t.column_widths = column_widths
        t.row(0).style(:align => :center)
      end
    end
  end

  def client_info
    fiscal_year = @fiscal_year
    report_date_ad = "#{Date.today} AD"
    report_date_bs = "#{ad_to_bs(Date.today)} BS"
    client = @share_transactions.first.client_account
    client_name = client.name_and_nepse_code
    client_type = client.client_type.titleize
    data = [
        ["Customer Name:", client_name, "Fiscal Year:", fiscal_year],
        ["Customer Type:", client_type, "Report Date:", report_date_bs + "\n" + report_date_ad]
    ]
    table_width = page_width - 2
    column_widths = {0 => table_width * 2/12.0, 1 => table_width * 6/12.0, 2 => table_width * 2/12.0, 3 => table_width * 2/12.0}
    table data do |t|
      t.header = true
      t.cell_style = {:border_width => 0, :padding => [0, 2, 0, 0]}
      t.column(-1).style(:align => :right)
      t.column_widths = column_widths
    end
  end

  def report_header
    report_type = "Customer Capital Gain Report"
    row_cursor = cursor
    bounding_box([0, row_cursor], :width => col(12)) do
      text report_type, :align => :center, :style => :bold
    end
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
    sub_regulation_notice_string = "\nSchedule 3\nRelating to Sub-Regulation(I) of Regulation 16\nInformation note to cients on execution of transaction"
    data = [
        [{:content => @current_tenant.full_name, :colspan => 2}],
        [@current_tenant.address, {:content => sub_regulation_notice_string, :colspan => 1, :rowspan => 4}],
        ["Phone: #{@current_tenant.phone_number}"],
        ["Fax: #{@current_tenant.fax_number}"],
        ["PAN: #{@current_tenant.pan_number}"]
    ]
    table_width = page_width - 2
    column_widths = {0 => table_width * 5/12.0, 1 => table_width * 7/12.0}
    table data do |t|
      t.header = true
      t.row(0).font_style = :bold
      t.row(0).size = 10
      t.column(1).style(:align => :center)
      t.cell_style = {:border_width => 0, :padding => [0, 2, 0, 0]}
      t.column_widths = column_widths
    end
    move_down 3
    hr
  end

end
