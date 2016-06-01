class Print::PrintSettlement< Prawn::Document
  require 'prawn/table'
  require 'prawn/measurement_extensions'

  include ApplicationHelper

  def initialize(settlement, current_tenant)
    super(top_margin: 12, right_margin: 28, bottom_margin: 18, left_margin: 18)

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
    568
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
      text "Received with thanks from: " +  "<b><u>#{@settlement.name}</u></b>", :inline_format => true
    else
      text "Paid to: " +  "<b><u>#{@settlement.name}</u></b>", :inline_format => true
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
      t.cell_style = {:border_width => 0, :padding => [0,2,0,0], :align => :left}
      t.column_widths = column_widths
      t.column(1).style(:align => :right)
    end
  end

  def header
    row_cursor = cursor
    bounding_box([0, row_cursor], :width => col(3)) do
      text "#{@current_tenant.full_name}"
      text "#{@current_tenant.address}"
      text "Phone: #{@current_tenant.phone_number}"
      text "Fax: #{@current_tenant.fax_number}"
      text "PAN: #{@current_tenant.pan_number}"
    end
    bounding_box([col(3), row_cursor - 20], :width => col(6)) do
      settlement_type = @settlement.receipt? ? 'RECEIPT' : 'PAYMENT'
      text "<b><u><i>" + settlement_type + "</i></u></b>" , :inline_format => true, :align => :center
      move_down (20)
    end
  end

  def signature_fields
    data = [
        ["" , "_" * 30, "_" * 30],
        ["", "Paid by", "Received by"]
    ]
    table_width = page_width - 2
    column_widths = {0 => table_width * 1/3.0, 1 => table_width * 1/3.0, 2 => table_width * 1/3.0}
    table(data, :column_widths => column_widths, :cell_style => {:border_width => 0, :padding => [0,2,0,0], :align => :center})
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
