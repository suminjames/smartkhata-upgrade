class Reports::Pdf::CommissionReport < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper
  include ShareTransactionsHelper

  def initialize(commission_reports, params, current_tenant, print_in_letter_head=nil)
    @commission_reports = commission_reports
    @params = params
    @current_tenant = current_tenant
    @print_in_letter_head = print_in_letter_head || false

    if @print_in_letter_head
      top_margin = 38.mm
      bottom_margin = 11.mm
    else
      top_margin = 12
      bottom_margin = 18
    end

    super(top_margin: top_margin, right_margin: 18, bottom_margin: bottom_margin, left_margin: 18)

    draw
  end

  def draw
    font_size(9) do
      move_down(3)
      company_header unless @print_in_letter_head
      report_header
      move_down(3)
      commission_reports_list
      generate_page_number
    end
  end

  def page_width
    558
  end

  def page_height
    770
  end

  def col(unit)
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
    # text "Commission Report.pdf"
  end

  def commission_reports_list
    table_data = []
    # table_data.unshift %w(id name address)
    th_data = [
      "S.no",
      "Client Name",
      "Total Transaction",
      "Total Quantity",
      "Total Amount",
      "Total Commission Paid"
    ]
    table_data << th_data
    @commission_reports.each_with_index do |share_transaction, index|
      td_data = [
        index + 1,
        share_transaction.client_account.name,
        share_transaction["transaction_count"],
        share_transaction["total_quantity"],
        share_transaction["total_amount"],
        share_transaction["total_commission_amount"]
      ]
      table_data << td_data
    end
    table_width = page_width - 2
    column_widths = {
      0 => table_width * 1 / 12.0, # sn
      1 => table_width * 3 / 12.0, # name
      2 => table_width * 2 / 12.0,   # trans
      3 => table_width * 2 / 12.0,   # qty
      4 => table_width * 2 / 12.0,   # amt
      5 => table_width * 2 / 12.0   # comm paid
    }

    table table_data do |t|
      t.cell_style = {border_width: 1, padding: [2, 4, 2, 2]}
      t.column(0).style(align: :center)
      t.column(1).style(align: :left)
      t.column(2).style(align: :center)
      t.column(3).style(align: :center)
      t.column(4).style(align: :right)
      t.column(5).style(align: :right)
      t.row(0).style(align: :center)
      t.row(0).font_style = :bold
      t.column_widths = column_widths
    end
  end

  def generate_page_number
    string = "page <page> of <total>"
    options = { at: [bounds.right - 150, 0],
                width: 150,
                align: :right,
                start_count_at: 1}
    number_pages string, options
  end

  def company_header
    row_cursor = cursor
    bounding_box([0, row_cursor], width: col(9)) do
      text "<b>#{@current_tenant.full_name}</b>", inline_format: true, size: 11
      text @current_tenant.address.to_s
      text "Phone: #{@current_tenant.phone_number}"
      text "Fax: #{@current_tenant.fax_number}"
      text "PAN: #{@current_tenant.pan_number}"
    end
    hr
  end

  def file_name
    "CommissionReport.pdf"
  end
end
