class Reports::Pdf::SecuritiesFlowsReport < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper
  include ShareTransactionsHelper

  def initialize(securities_flows, is_securities_balance_view, params, current_tenant, print_in_letter_head=nil)
    @securities_flows = securities_flows
    @is_securities_balance_view = is_securities_balance_view
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

    super(top_margin: top_margin, right_margin: 38, bottom_margin: bottom_margin, left_margin: 18)

    draw
  end

  def draw
    font_size(9) do
      move_down(3)
      company_header unless @print_in_letter_head
      report_header
      move_down(3)
      securities_flows_list
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
    report_headings = report_headings_for_securities_flow(@params, @is_securities_balance_view)
    table_data = []
    report_headings.each do |heading|
      table_data << [heading]
    end
    table_width = page_width - 2
    column_widths = {
        0 => table_width * 12/12.0,
    }
    table table_data do |t|
      t.cell_style = {:border_width => 0, :padding => [2, 4, 2, 2]}
      t.column(0).style(:align => :center)
      t.column(0).font_style = :bold
      t.column_widths = column_widths
    end

  end


  def securities_flows_list
    table_data = []
    th_data = [
        "SN.",
        "Company",
        "Quantity\nIn",
        "Quantity\nOut",
        "Quantity\nBalance"
    ]
    if @is_securities_balance_view
      th_data.delete_at(2)
      th_data.delete_at(2)
    end
    table_data << th_data
    @securities_flows.each_with_index do |securities_flow, index|
      isin_info = IsinInfo.find(securities_flow["isin_info_id"])

      td_data = [
          index + 1,
          "#{isin_info.isin}\n#{isin_info.company}",
          securities_flow["quantity_in_sum"],
          securities_flow["quantity_out_sum"],
          securities_flow["quantity_balance"]
      ]
      if @is_securities_balance_view
        td_data.delete_at(2)
        td_data.delete_at(2)
      end
      table_data << td_data
    end

    table_width = page_width - 2
    if @is_securities_balance_view
      column_widths = {
      }
    else
      column_widths = {
          0 => table_width * 0.6/12.0,
          1 => table_width * 4.8/12.0,
          2 => table_width * 2.2/12.0,
          3 => table_width * 2.2/12.0,
          4 => table_width * 2.2/12.0,
      }
    end

    table table_data do |t|
      t.cell_style = {:border_width => 1, :padding => [2, 4, 2, 2]}
      t.column(0).style(:align => :right)
      t.column(1).style(:align => :center)
      t.column(2).style(:align => :right)
      t.column(3).style(:align => :right)
      t.column(4).style(:align => :right)
      t.row(0).style(:align => :center)
      t.row(0).font_style = :bold
      t.column_widths = column_widths
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

  def file_name
    @is_securities_balance_view ? 'Securities_Balances.pdf' : 'Securities_Flow_Register.pdf'
  end

end
