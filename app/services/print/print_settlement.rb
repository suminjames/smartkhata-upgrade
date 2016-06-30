class Print::PrintSettlement< Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper

  def initialize(settlement, current_tenant)
    super(top_margin: 12, right_margin: 38, bottom_margin: 18, left_margin: 18)

    @settlement = settlement
    @current_tenant = current_tenant

    draw
  end

  def draw
    font_size(9) do
      move_down(3)
      header
      hr
      settlement_no_row
      move_down(3)
      details_section
      move_down(15)
      signature_fields
      move_down(5)
      hr
      move_down(2)
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

  def details_section
    if @settlement.receipt?
      text "Received with thanks from: " + "<b><u>#{@settlement.name}</u></b>", :inline_format => true
    else
      text "Paid to: " + "<b><u>#{@settlement.name}</u></b>", :inline_format => true
    end
    text "the sum of <b>Rs. #{arabic_number(@settlement.amount)}</b>", :inline_format => true
    text "(in words) <u><b> #{arabic_word(@settlement.amount)}</b></u>", :inline_format => true

    move_down(1)

    if @settlement.voucher.cheque_entries.present?
      text 'By Cheque:'
      @settlement.voucher.cheque_entries.uniq.each do |cheque|
        bank = cheque.receipt? ? cheque.additional_bank.name : cheque.bank_account.bank_name
        text nbsp * 4 + "Cheque Number: <i>#{cheque.cheque_number}</i>   Bank: <i>#{bank}</i>   Amount: <i>#{cheque.amount}</i>", :inline_format => true
      end
    end
  end

  def settlement_no_row
    cell_0_1_data = @settlement.receipt? ? 'Receipt No: ' : 'Payment No: '
    cell_0_1_data += @settlement.id.to_s
    cell_0_2_data = 'Date: ' + @settlement.date_bs
    data = [
        [cell_0_1_data, cell_0_2_data]
    ]
    table_width = page_width - 2
    column_widths = {0 => table_width * 1/2.0, 1 => table_width * 1/2.0}
    table data do |t|
      t.header = true
      t.cell_style = {:border_width => 0, :padding => [0, 2, 0, 0], :align => :left}
      t.column_widths = column_widths
      t.column(1).style(:align => :right)
    end
  end

  def header
    row_cursor = cursor
    settlement_type = @settlement.receipt? ? 'RECEIPT' : 'PAYMENT'
    data = [
        [{:content => @current_tenant.full_name, :colspan => 2}],
        [@current_tenant.address, {:content => settlement_type, :colspan => 1, :rowspan => 4}],
        ["Phone: #{@current_tenant.phone_number}"],
        ["Fax: #{@current_tenant.fax_number}"],
        ["PAN: #{@current_tenant.pan_number}"]
    ]
    table_width = page_width - 2
    column_widths = {0 => table_width * 6/12.0, 1 => table_width * 6/12.0}
    table data do |t|
      t.header = true
      t.row(0).font_style = :bold
      t.row(0).size = 10
      t.row(1).column(1).font_style = :bold_italic
      t.cell_style = {:border_width => 0, :padding => [0, 2, 0, 0]}
      t.column_widths = column_widths
    end
    move_down 3
  end

  def signature_fields
    data = [
        ["", "_" * 30, "_" * 30],
        ["", "Paid by", "Received by"]
    ]
    table_width = page_width - 2
    column_widths = {0 => table_width * 1/3.0, 1 => table_width * 1/3.0, 2 => table_width * 1/3.0}
    table(data, :column_widths => column_widths, :cell_style => {:border_width => 0, :padding => [0, 2, 0, 0], :align => :center})
  end

  def footer
    text @settlement.description
    if @settlement.receipt?
      text '<u><i>Note: Please bring this receipt compulsarily while claiming unpurchase share.</i></u>', :inline_format => true
    end
  end

  def nbsp
    "\xC2\xA0"
  end

end
