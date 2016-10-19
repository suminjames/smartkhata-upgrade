class Print::PrintMultipleBills < Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  def initialize(bills, current_tenant, print_type)
    super(top_margin: 12, right_margin: 38, bottom_margin: 18, left_margin: 18)

    @current_tenant = current_tenant
    # @print_type is one of the strings: 'for_print', 'for_email'
    @print_type = print_type

    bills.each_with_index do |bill, index|
      @bill = bill
      draw
      if index != bills.length-1
        start_new_page
      end
    end

  end

  def draw
    font_size(9) do
      move_down(3)
      header
      hr
      bill_no_row
      customer_details_row
      move_down(5)
      bill_message
      share_transactions_section
      move_down(3)
      calculation_section
      move_down(3)
      footer
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

  def bill_no_row
    row_cursor = cursor
    bounding_box([0, row_cursor], :width => col(4)) do
      text "Bill No: #{@bill.formatted_bill_number}"
    end
    bounding_box([col(4), row_cursor], :width => col(5)) do
      text "Bill Date: #{@bill.formatted_bill_dates["ad"]} (#{@bill.formatted_bill_dates["bs"]})"
    end
    bounding_box([col(9), row_cursor], :width => col(3)) do
      text "Fiscal Year: #{@bill.formatted_fy_code}", :align => :right
    end
  end

  def header
    row_cursor = cursor
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
  end

  def footer
    if @print_type == 'for_email'
      text "<u><i>Note: This is computer generated document, and therefore doesn't have a signature. </i></u>", :inline_format => true
    elsif @print_type == 'for_print'
      text "<u><i>Note: Please bring this bill for enquiry and further processing.</i></u>", :inline_format => true
    end
    text "**Company Code Index => <i>#{@bill.formatted_isin_abbreviation_index}</i>", :inline_format => true
  end

  def bill_message
    text @bill.formatted_bill_message
  end

  def customer_details_row
    data =[
        ["Customer:", @bill.formatted_client_name, "Contact No.:", @bill.formatted_client_phones_first_row],
        ["NEPSE Code:", @bill.client.nepse_code, "", @bill.formatted_client_phones_second_row]
    ]
    table_width = page_width - 2
    column_widths = {0 => table_width * 0.15, 1 => table_width * 0.42, 2 => table_width * 0.13, 3 => table_width * 0.30}
    table data do |t|
      t.header = true
      t.cell_style = {:border_width => 0, :padding => [0, 2, 0, 0], :align => :left}
      t.column_widths = column_widths
      t.column(2).style(:align => :left)
      t.column(3).style(:align => :right)
    end
  end

  def calculation_section
    row_cursor = cursor
    bounding_box([0, row_cursor], :width => col(6)) do
      tr_data = [
          ["Share Amount:", @bill.formatted_net_share_amount],
          ["SEBO Commission:", @bill.formatted_net_sebo_commission],
          ["Net Commission Amount:", @bill.formatted_net_commission],
          ["DP Fee:", @bill.formatted_net_dp_fee],
          ["Capital Gain:", @bill.formatted_net_cgt],
          ["Net Receivable Amount:", @bill.formatted_net_receivable_amount],
          ["Net Payable Amount:", @bill.formatted_net_payable_amount]
      ]
      if @bill.bill_type == 'purchase'
        tr_data.delete_at(4)
        tr_data.delete_at(5)
      end
      if @bill.bill_type == 'sales'
        tr_data.delete_at(5)
      end
      table(tr_data, :cell_style => {:border_width => 0, :padding => [0, 2, 0, 2], :align => :right})
    end

    bounding_box([col(6)+col(1), row_cursor], :width => col(5)) do
      data = [
          ["Transaction Date:", @bill.formatted_transaction_dates['ad'] +" (" + @bill.formatted_transaction_dates['bs'] +")"]
      ]
      if @bill.purchase?
        data.insert(0, ["Clearance Date:", @bill.formatted_clearance_dates['ad'] +" (" + @bill.formatted_clearance_dates['bs'] +")"])
      end
      table(data, :position => :right, :cell_style => {:border_width => 0, :padding => [0, 2, 0, 2], :align => :right})

      move_down(30)

      if @print_type != 'for_email'
        text "_" * 35, :align => :center
        text "(Authorized Signature)", :align => :center
      end
      text @current_tenant.full_name, :align => :center
      text "Broker Code No.: #{@current_tenant.broker_code}", :align => :center
      text "Nepal Stock Exchange", :align => :center
    end
  end

  def share_transactions_section
    row_cursor = cursor
    bounding_box([0, row_cursor], :width => col(12)) do

      data = []
      th_data = ["Transaction No", "No of Shares", "Company Code", "Share Rate", "Base Price", "Amount", "Commission", "Commission Amount", "Capital Gain Tax"]
      if @bill.bill_type == 'purchase'
        th_data.delete_at(4)
        th_data.delete_at(7)
      end

      data << th_data
      @bill.formatted_group_same_isin_same_rate_transactions.each do |formatted_share_transaction|
        row_data = [
            formatted_share_transaction[:contract_no],
            "#{formatted_share_transaction[:raw_quantity]}#{formatted_share_transaction[:raw_quantity_description]}",
            formatted_share_transaction[:isin],
            formatted_share_transaction[:share_rate],
            formatted_share_transaction[:base_price],
            formatted_share_transaction[:share_amount],
            formatted_share_transaction[:commission_rate],
            formatted_share_transaction[:commission_amount],
            formatted_share_transaction[:capital_gain]
        ]
        if @bill.bill_type == 'purchase'
          row_data.delete_at(4)
          row_data.delete_at(7)
        end
        data << row_data
      end

      table_width = page_width - 2

      if @bill.bill_type == 'purchase'
        column_widths = {0 => table_width * 0.26,
                         1 => table_width * 0.20,
                         2 => table_width * 0.09,
                         3 => table_width * 0.09,
                         5 => table_width * 0.12,
                         6 => table_width * 0.13,
                         7 => table_width * 0.11}
      else # if @bill.bill_type == 'sales'
        column_widths = {0 => table_width * 0.25,
                         1 => table_width * 0.17,
                         2 => table_width * 0.07,
                         3 => table_width * 0.07,
                         4 => table_width * 0.07,
                         5 => table_width * 0.10,
                         6 => table_width * 0.09,
                         7 => table_width * 0.09,
                         8 => table_width * 0.09}
      end
      table data do |t|
        t.header = true
        t.row(0).font_style = :bold
        t.cell_style = {:size => 8, :padding => [2, 2, 2, 2], :align => :center}
        t.width = table_width
        t.column_widths = column_widths
      end
    end
  end

end
